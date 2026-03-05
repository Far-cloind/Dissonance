---
name: "godot-2d-game-setup"
description: "创建完整的Godot 4 2D游戏项目结构，包含玩家移动、敌人系统、战斗和UI。当用户想要创建类似吸血鬼幸存者（土豆兄弟）的2D游戏时调用。"
---

# Godot 2D 游戏项目搭建

本 Skill 用于在 Godot 4 中创建完整的 2D 游戏项目结构，类似吸血鬼幸存者（土豆兄弟）风格的游戏。

## 创建的项目结构

```
project/
├── project.godot          # 项目配置文件
├── scenes/
│   ├── main.tscn         # 主游戏场景
│   ├── player.tscn       # 玩家角色场景
│   ├── enemy.tscn        # 敌人基础场景
│   ├── enemy_spawner.tscn # 敌人生成系统
│   ├── shockwave.tscn    # 玩家攻击特效
│   └── game_ui.tscn      # UI界面（血量、经验、时间）
├── scripts/
│   ├── main.gd           # 主游戏逻辑
│   ├── player.gd         # 玩家移动和战斗
│   ├── enemy.gd          # 敌人AI
│   ├── enemy_spawner.gd  # 生成逻辑
│   ├── shockwave.gd      # 攻击特效逻辑
│   └── game_ui.gd        # UI更新
└── assets/               # 美术资源文件夹
```

## 核心功能

### 1. 玩家系统
- 鼠标跟随移动
- 自动攻击（每秒释放冲击波）
- 血量系统（10点HP）
- 经验值和升级

### 2. 敌人系统
- 在屏幕边缘自动生成
- 追踪并追击玩家
- 一击必杀
- 死亡给予经验值

### 3. 战斗系统
- 扩散型冲击波攻击
- 碰撞检测
- 伤害处理

### 4. UI系统
- 血量条（红色）
- 经验条（蓝色）
- 等级显示
- 游戏计时器

## Godot 编辑器操作指南

### 创建场景
1. **新建场景**：右键文件夹 → `新建场景`
2. **添加节点**：右键节点 → `添加子节点`
3. **实例化场景**：右键节点 → `实例化子场景`
4. **附加脚本**：选中节点 → 检查器 → 脚本属性

### 常用节点类型
- **CharacterBody2D**：玩家和敌人（带碰撞）
- **Area2D**：攻击判定框和触发器
- **CanvasLayer**：UI元素（始终在最上层）
- **ProgressBar**：血量/经验条
- **Label**：文本显示
- **Timer**：延迟动作

### 设置进度条颜色
1. 选中 ProgressBar 节点
2. 在检查器中：`Theme Overrides > Styles > Fill`
3. 点击 `<空>` → `新建 StyleBoxFlat`
4. 设置 `Bg Color`（背景颜色）：
   - 血量条：红色 (255, 0, 0)
   - 经验条：蓝色 (0, 150, 255)

### 重要提示

1. **UID 问题**：如果场景打不开，检查脚本 UID 是否与 `.gd.uid` 文件和 `.tscn` 引用匹配

2. **碰撞层设置**：
   - 玩家：Layer 1
   - 敌人：Layer 2
   - 攻击：检测 Layer 2

3. **分组**：使用 `add_to_group("player")` / `add_to_group("enemy")` 方便查找

4. **导出变量**：使用 `@export` 使变量可在检查器中编辑

5. **场景引用**：使用 `preload("res://path/to/scene.tscn")` 预加载场景

## 常见错误及修复

| 错误 | 解决方案 |
|------|----------|
| "Script inherits from native type 'X', can't be assigned to object of type 'Y'" | 清除 .godot 缓存或重新加载项目 |
| "Invalid scene: node does not specify its parent node" | 在 .tscn 中给子节点添加 `parent="."` |
| UID 不匹配 | 删除 .godot 文件夹，让 Godot 重新生成 |

## 搭建完成后的下一步

1. 运行游戏测试基础功能
2. 调整平衡性（速度、伤害、生成率）
3. 添加美术资源替换占位符
4. 添加音效和音乐
5. 实现更多武器类型
6. 添加升级/商店系统
