extends InstrumentStyleBase

# 弦乐风格 - 使用大提琴和小提琴，慢节奏

class_name StringStyle

func _init():
	style_name = "弦乐风格"
	bpm = 90.0  # 弦乐更慢更优雅

func get_rhythm_manager_script() -> String:
	# 弦乐风格使用特殊的华尔兹节奏管理器
	return "res://scripts/managers/rhythm_managers/string_rhythm_manager.gd"

func play_strong_beat(player: Node2D) -> bool:
	# 弦乐风格：调用玩家的弦乐攻击
	if player.has_method("play_string_attack"):
		player.play_string_attack()
		return true
	return false

func play_weak_beat(rhythm_manager: Node) -> bool:
	# 弦乐风格：播放小提琴高音
	var string_synth = rhythm_manager.get_node_or_null("StringSynth")
	if string_synth and string_synth.has_method("play_high_string"):
		string_synth.play_high_string()
		print("🎻 小提琴高音")
		return true
	return false

func get_description() -> String:
	return "优雅弦乐风格，BPM 90，使用大提琴和小提琴的古典华尔兹"
