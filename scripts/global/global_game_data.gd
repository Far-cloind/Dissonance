extends Node

# 全局游戏数据 - 跨场景保存数据

# 选择的乐器风格
var selected_style: int = 0  # 默认摇滚风格

# 乐器风格常量
const STYLE_ROCK: int = 0
const STYLE_ELECTRONIC: int = 1
const STYLE_STRING: int = 2

func _ready():
	print("全局游戏数据初始化完成")
