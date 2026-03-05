---
name: "godot-debug-guide"
description: "提供Godot 4常见错误的解决方案和调试技巧。当用户遇到Godot错误、场景加载问题、UID不匹配、脚本分配问题或UI不更新问题时调用。"
---

# Godot 4 调试指南

本 Skill 提供 2D 游戏开发中常见的 Godot 4 错误解决方案。

## 常见错误及解决方案

### 1. 脚本类型不匹配错误
**错误信息：**
```
Script inherits from native type 'CharacterBody2D', so it can't be assigned to an object of type: 'Node2D'
```

**原因：**
- 脚本的 `extends` 语句与节点类型不匹配
- Godot 缓存了旧的脚本信息
- 脚本和场景引用之间的 UID 不匹配

**解决方案：**
1. 检查脚本的 `extends` 语句是否与节点类型匹配：
   ```gdscript
   # CharacterBody2D 节点
   extends CharacterBody2D
   
   # Node2D 节点
   extends Node2D
   ```

2. 清除 Godot 缓存：
   - 关闭 Godot
   - 删除 `.godot` 文件夹
   - 重新打开项目

3. 重新加载项目：`项目 → 重新加载当前项目`

4. 在检查器中重新附加脚本

---

### 2. 场景加载错误
**错误信息：**
```
ERROR: Invalid scene: node CollisionShape2D does not specify its parent node.
ERROR: Failed to load scene dependency: "res://scenes/xxx.tscn"
```

**原因：**
.tscn 文件中的子节点缺少 `parent="."` 属性

**解决方案：**
给所有子节点添加 `parent="."`：
```
[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
```

---

### 3. UID 不匹配错误
**症状：**
- 场景能打开但脚本不工作
- 变量不在检查器中显示
- "无法加载脚本"警告

**诊断：**
检查文件中的 UID：
```bash
# 检查脚本 UID
cat scripts/player.gd.uid
# 输出: uid://bd2hkdglaiw6e

# 检查场景引用
cat scenes/player.tscn | grep ext_resource
# 应该匹配: uid://bd2hkdglaiw6e
```

**解决方案：**
1. 从 `.gd.uid` 文件获取正确的 UID
2. 更新场景文件的 `ext_resource` 行
3. 或删除 `.godot` 文件夹重新生成

---

### 4. 导出变量不显示
**症状：**
- `@export var` 不在检查器中显示
- 变量显示为 `<null>`

**解决方案：**
1. 确保脚本正确附加（无错误）
2. 检查脚本没有语法错误
3. 重新加载场景或项目
4. 验证 `@export` 语法：
   ```gdscript
   @export var move_speed: float = 300.0
   @export var max_health: int = 10
   ```

---

### 5. 碰撞不工作
**症状：**
- `body_entered` 信号不触发
- 物体相互穿过

**检查清单：**
1. 两个物体都有碰撞形状
2. 碰撞层/掩码正确：
   ```gdscript
   # 玩家
   collision_layer = 1
   collision_mask = 2  # 检测敌人
   
   # 敌人
   collision_layer = 2
   collision_mask = 1  # 检测玩家
   ```
3. 至少一个物体在移动（碰撞检测需要运动）
4. 对于 Area2D：`monitoring = true` 和 `monitorable = true`

---

### 6. 场景实例找不到（Nil 错误）
**错误：**
```
Invalid call. Nonexistent function 'xxx' in base 'Nil'.
```

**原因：**
- 节点还没被添加到场景树
- `_ready()` 执行顺序问题
- 使用 `@onready` 的节点在 `_ready()` 中还没初始化

**解决方案：**

**方法 1：使用 call_deferred 延迟查找**
```gdscript
func _ready():
	# 延迟到下一帧再查找
	call_deferred("find_player")

func find_player():
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("找到玩家:", player.name)
	else:
		# 如果没找到，继续重试
		call_deferred("find_player")
```

**方法 2：使用 @onready 等待场景树**
```gdscript
@onready var player = $Player
```

**方法 3：使用分组全局查找**
```gdscript
# 在玩家脚本中
func _ready():
	add_to_group("player")

# 在UI脚本中
var player = get_tree().get_first_node_in_group("player")
```

---

### 7. UI 不更新
**症状：**
- UI 元素显示默认值不变化
- 进度条不更新
- 标签文本不变

**检查清单：**

1. **检查节点引用是否为 null**
   ```gdscript
   func update_health_ui():
	   if player == null:
		   return  # 提前返回避免错误
	   # 更新UI...
   ```

2. **检查 _ready() 执行顺序**
   - UI 的 `_ready()` 可能在目标节点之前执行
   - 使用 `call_deferred()` 延迟初始化

3. **检查变量名拼写**
   ```gdscript
   # 错误示例
   health_bar.value = current_health  # 如果 health_bar 是 null 会崩溃
   
   # 正确示例
   if health_bar != null:
	   health_bar.value = current_health
   ```

4. **添加调试打印**
   ```gdscript
   func _process(delta):
	   if player != null:
		   print("血量:", player.current_health, "/", player.max_health)
		   update_health_ui()
   ```

---

### 8. 方法调用参数错误
**错误：**
```
Invalid call to function 'take_damage' in base 'CharacterBody2D (enemy.gd)'. Expected 1 argument(s).
```

**原因：**
- 调用方法时参数数量不匹配
- 函数定义需要参数，但调用时没传

**解决方案：**
```gdscript
# 函数定义
func take_damage(damage: int):
	pass

# 错误调用
body.take_damage()  # ❌ 缺少参数

# 正确调用
body.take_damage(1)  # ✅ 传递参数
body.take_damage(damage)  # ✅ 使用变量
```

---

### 9. Preload/Load 错误
**错误：**
```
Parse Error: Couldn't find the given scene file
```

**解决方案：**
1. 检查文件路径是否正确（区分大小写）
2. 使用 `preload()` 编译时加载：
   ```gdscript
   @onready var scene = preload("res://scenes/enemy.tscn")
   ```
3. 使用 `load()` 动态加载：
   ```gdscript
   var scene = load("res://scenes/enemy.tscn")
   ```
4. 在文件系统面板中验证文件存在

---

## 调试技巧

### 1. Print 调试
```gdscript
func _process(delta):
    print("位置: ", global_position)
    print("速度: ", velocity)
```

### 2. 远程场景树
1. 按 `F5` 运行游戏
2. 切换到 `远程` 场景树标签
3. 检查实时节点层次结构

### 3. 断点
1. 在脚本编辑器左侧边距点击
2. 出现红点 = 断点已设置
3. 执行到该行时游戏暂停
4. 使用 `F10`（逐过程）、`F11`（逐语句）

### 4. 监控变量
```gdscript
# 在 _process 中监控重要值
func _process(delta):
    if OS.is_debug_build():
        $DebugLabel.text = "血量: %d\n经验: %d" % [health, exp]
```

### 5. 错误检查模式
```gdscript
func get_player():
    var player = get_tree().get_first_node_in_group("player")
    if player == null:
        push_error("找不到玩家！")
        return null
    return player
```

---

## 预防建议

1. **始终使用分组**查找节点：
   ```gdscript
   add_to_group("player")
   get_tree().get_first_node_in_group("player")
   ```

2. **使用 @onready**引用节点：
   ```gdscript
   @onready var sprite = $Sprite2D
   ```

3. **使用前检查 null**：
   ```gdscript
   if player != null and player.has_method("take_damage"):
       player.take_damage(10)
   ```

4. **处理 _ready() 执行顺序**：
   ```gdscript
   func _ready():
	   call_deferred("delayed_init")
   
   func delayed_init():
	   # 在这里查找其他节点
	   pass
   ```

5. **频繁保存场景**，使用 `Ctrl+S`

6. **增量测试** - 每次重大更改后运行

7. **使用版本控制**（Git）跟踪更改

---

## 快速修复清单

| 问题 | 快速修复 |
|------|----------|
| 场景打不开 | 删除 `.godot` 文件夹 |
| 脚本不工作 | 在检查器中重新附加 |
| 变量不显示 | 重新加载项目 |
| 碰撞不工作 | 检查层/掩码 |
| 找不到节点 | 检查组和路径，使用 call_deferred |
| UI 不更新 | 检查 null，添加调试打印 |
| 方法调用错误 | 检查参数数量和类型 |
| 游戏崩溃 | 检查远程场景树 |
