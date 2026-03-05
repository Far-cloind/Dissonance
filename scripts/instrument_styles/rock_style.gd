extends InstrumentStyleBase

# 摇滚风格 - 使用底鼓和军鼓，快节奏

class_name RockStyle

func _init():
	style_name = "摇滚风格"
	bpm = 140.0  # 摇滚更快

func get_rhythm_manager_script() -> String:
	# 摇滚风格使用标准四二拍节奏管理器
	return "res://scripts/managers/rhythm_managers/rock_rhythm_manager.gd"

func play_strong_beat(player: Node2D) -> bool:
	# 摇滚风格：调用玩家的摇滚攻击
	if player.has_method("play_rock_attack"):
		player.play_rock_attack()
		return true
	return false

func play_weak_beat(rhythm_manager: Node) -> bool:
	# 摇滚风格：播放军鼓
	var snare_synth = rhythm_manager.get_node_or_null("SnareSynth")
	if snare_synth and snare_synth.has_method("play_snare"):
		snare_synth.play_snare()
		print("🥁 摇滚军鼓")
		return true
	return false

func get_description() -> String:
	return "经典摇滚风格，BPM 140，使用底鼓和军鼓的强力节奏"
