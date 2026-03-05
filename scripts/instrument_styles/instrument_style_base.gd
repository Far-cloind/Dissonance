extends RefCounted

# 乐器风格基类 - 定义乐器风格的接口

class_name InstrumentStyleBase

# 风格名称
var style_name: String = "Base Style"

# BPM（每风格可以有不同的节奏）
var bpm: float = 120.0

# 初始化
func _init():
	pass

# 获取该风格的节奏管理器脚本路径
func get_rhythm_manager_script() -> String:
	return "res://scripts/managers/rhythm_manager.gd"

# 强拍时调用 - 返回是否成功播放
func play_strong_beat(player: Node2D) -> bool:
	return false

# 弱拍时调用 - 返回是否成功播放
func play_weak_beat(rhythm_manager: Node) -> bool:
	return false

# 获取风格描述
func get_description() -> String:
	return "基础乐器风格"
