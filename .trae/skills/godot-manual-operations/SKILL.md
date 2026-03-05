---
name: "godot-manual-operations"
description: "Provides step-by-step instructions for manual Godot Engine operations. Invoke when user asks how to perform actions in Godot editor UI instead of writing .tscn files directly."
---

# Godot 引擎手动操作指南

本 skill 提供在 Godot 编辑器中手动执行操作的详细步骤，适用于需要用户自己在引擎中操作的情况。

## 基本原则

1. **不写 .tscn 文件** - 只提供 GDScript 代码和操作说明
2. **详细步骤** - 每个操作都提供清晰的步骤说明
3. **Godot 4.x 版本** - 基于 Godot 4.x 的界面布局

## 常用操作指南

### 1. 添加子节点

**场景：** 需要给节点添加子节点

**步骤：**
1. 在**场景面板**（Scene dock）中选择父节点
2. 右键点击 → **添加子节点**（Add Child Node）
3. 在弹出的对话框中：
   - 搜索节点类型（如 `AudioStreamPlayer`）
   - 点击 **创建**（Create）
4. 在**检查器**（Inspector）中设置节点名称

### 2. 附加脚本

**场景：** 给节点附加 GDScript 脚本

**步骤：**
1. 选择目标节点
2. 在检查器中找到 **Script** 属性
3. 点击 `<空>` 或当前脚本路径
4. 选择 **加载**（Load）或 **创建**（Create）
   - 加载：选择已有的 .gd 文件
   - 创建：设置脚本路径和模板

### 3. 设置节点属性

**场景：** 修改节点属性

**步骤：**
1. 选择节点
2. 在检查器中找到对应属性
3. 修改值：
   - 数字：直接输入或拖动
   - 颜色：点击颜色框选择
   - 枚举：下拉选择
   - 资源：拖拽或点击加载

### 4. 连接信号

**场景：** 连接按钮点击等信号

**步骤：**
1. 选择发送信号的节点（如 Button）
2. 在检查器中点击 **节点**（Node）标签
3. 找到要连接的信号（如 `pressed`）
4. 双击信号或点击 **连接**（Connect）
5. 在对话框中：
   - 选择目标节点
   - 设置接收方法名
   - 点击 **连接**

### 5. 设置碰撞层和掩码

**场景：** 配置 CollisionLayer 和 CollisionMask

**步骤：**
1. 选择碰撞体节点（如 CharacterBody2D）
2. 在检查器中找到：
   - **Collision > Layer**（碰撞层）
   - **Collision > Mask**（碰撞掩码）
3. 点击展开，勾选对应层（1-32）

### 6. 添加自动加载（AutoLoad）

**场景：** 添加全局脚本

**步骤：**
1. 点击 **项目**（Project）菜单
2. 选择 **项目设置**（Project Settings）
3. 切换到 **自动加载**（AutoLoad）标签
4. 点击文件夹图标选择脚本
5. 设置节点名称
6. 点击 **添加**（Add）

### 7. 设置主场景

**场景：** 修改游戏启动场景

**步骤：**
1. 点击 **项目**（Project）菜单
2. 选择 **项目设置**（Project Settings）
3. 在 **应用 > 运行**（Application > Run）中
4. 找到 **主场景**（Main Scene）
5. 选择场景文件

### 8. 创建 PackedScene 预加载

**场景：** 在脚本中预加载场景

**GDScript 代码：**
```gdscript
@onready var scene_to_spawn: PackedScene = preload("res://scenes/my_scene.tscn")
```

**手动操作：**
1. 不需要手动操作，直接写代码即可
2. 确保路径正确（相对于 res://）

### 9. 添加音频生成器

**场景：** 创建程序化音频

**步骤：**
1. 添加 **AudioStreamPlayer** 节点
2. 在检查器中：
   - **Stream** 属性点击 `<空>`
   - 选择 **新建 AudioStreamGenerator**
3. 附加脚本，继承 `AudioStreamPlayer`
4. 在 `_ready()` 中配置生成器参数

### 10. 保存和运行

**快捷键：**
- **保存场景**：Ctrl + S
- **保存所有**：Ctrl + Shift + S
- **运行项目**：F5
- **运行当前场景**：F6
- **停止**：F8

## 最佳实践

1. **频繁保存** - 使用 Ctrl + S 经常保存
2. **使用版本控制** - 配合 Git 管理项目
3. **组织文件** - 使用文件夹组织 scenes、scripts、assets
4. **命名规范** - 使用小写和下划线命名（snake_case）

## 故障排除

### 场景无法加载
- 检查文件路径是否正确
- 检查 UID 是否匹配
- 尝试删除 .godot 文件夹重新导入

### 脚本错误
- 检查 extends 语句是否正确
- 检查节点路径是否正确
- 查看调试器（Debugger）面板的错误信息

### 音频不播放
- 检查 AudioStreamPlayer 是否已添加到场景树
- 检查音量是否被设置为 0
- 检查是否调用了 play() 方法
