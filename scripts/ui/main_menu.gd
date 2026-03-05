extends Control

# 乐器风格枚举
enum InstrumentStyle {
	ROCK,      # 摇滚风格
	ELECTRONIC,# 电子风格（预留）
	STRING     # 弦乐风格
}

# 当前选择的风格
var current_style: int = InstrumentStyle.ROCK

@onready var style_selector: OptionButton = $StyleSelector

func _ready():
	# 添加乐器风格选项
	style_selector.add_item("🎸 摇滚风格", InstrumentStyle.ROCK)
	style_selector.add_item("🎹 电子风格（开发中）", InstrumentStyle.ELECTRONIC)
	style_selector.add_item("🎻 弦乐风格", InstrumentStyle.STRING)
	
	# 设置默认选择
	style_selector.select(0)
	
	# 连接选择变化信号
	style_selector.item_selected.connect(_on_style_selected)

func _on_style_selected(index: int):
	current_style = index
	print("选择乐器风格:", style_selector.get_item_text(index))

func _on_start_button_pressed():
	# 保存选择的风格到全局数据
	GlobalGameData.selected_style = current_style
	print("开始游戏，乐器风格:", current_style)
	
	# 切换到主游戏场景
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	print("退出游戏")
	get_tree().quit()
