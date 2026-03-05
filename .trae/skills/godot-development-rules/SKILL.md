---
name: "godot-development-rules"
description: "Godot development rules and constraints. Invoke at the start of every Godot task to ensure compliance with project rules."
---

# Godot Development Rules

## Critical Rules

### 1. NEVER Modify .tscn Files
- **绝对禁止**直接修改 `.tscn` 场景文件
- 所有场景修改必须通过 Godot 编辑器手动完成
- 如果需要修改场景，提供详细的步骤说明让用户自己操作

### 2. Script-Only Modifications
- 只能修改 `.gd` 脚本文件
- 通过脚本动态创建节点和修改场景
- 使用 `Node.new()`、`add_child()` 等 API 在运行时构建场景

### 3. File Organization
- 脚本放在 `scripts/` 目录下，按功能分类
- 音频相关：`scripts/audio/`
- 角色相关：`scripts/characters/`
- UI相关：`scripts/ui/`
- 管理器：`scripts/managers/`

### 4. Code Style
- 使用 GDScript 官方风格指南
- 变量名使用 snake_case
- 类名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE

### 5. Safety Checks
- 修改脚本前，先读取确认内容
- 使用 `has_method()`、`get_node_or_null()` 等安全调用
- 避免直接访问可能不存在的节点

## Workflow

1. 读取需要修改的脚本
2. 在脚本中实现功能（不碰 .tscn）
3. 如果需要场景修改，提供手动操作步骤
4. 验证脚本语法正确

## Remember

> **永远不要修改 .tscn 文件！**
