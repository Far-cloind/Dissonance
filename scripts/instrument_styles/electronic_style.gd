extends InstrumentStyleBase

# 电子风格 - 使用合成器音色，中等速度

class_name ElectronicStyle

func _init():
	style_name = "电子风格"
	bpm = 128.0  # 电子音乐常用速度

func get_rhythm_manager_script() -> String:
	# 电子风格使用特殊的四四拍节奏管理器
	return "res://scripts/managers/rhythm_managers/electronic_rhythm_manager.gd"

func play_strong_beat(player: Node2D) -> bool:
	# 电子风格：调用玩家的电子攻击
	if player.has_method("play_electronic_attack"):
		player.play_electronic_attack()
		return true
	return false

func play_weak_beat(rhythm_manager: Node) -> bool:
	# 电子风格：播放电子军鼓/拍手声
	var snare_synth = rhythm_manager.get_node_or_null("SnareSynth")
	if snare_synth and snare_synth.has_method("play_snare"):
		# 可以在这里修改参数实现电子音色
		snare_synth.play_snare()
		print("🎹 电子军鼓")
		return true
	return false

func get_description() -> String:
	return "现代电子风格，BPM 128，使用合成器音色的四四拍节奏"
