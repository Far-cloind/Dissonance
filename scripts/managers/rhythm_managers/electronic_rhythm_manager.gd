extends Node

# 电子节奏管理器 - 四四拍，House/Techno风格

@export var bpm: float = 128.0

var beat_duration: float = 0.0
var beat_timer: float = 0.0
var current_beat: int = 0  # 1, 2, 3, 4

var death_queue: Array = []

var instrument_style: InstrumentStyleBase = null

@onready var snare_synth: AudioStreamPlayer = $SnareSynth
@onready var kick_synth: AudioStreamPlayer = $KickSynth

func _ready():
	add_to_group("rhythm_manager")
	
	# 创建乐器风格实例
	var style_type = GlobalGameData.selected_style
	instrument_style = StyleFactory.create_style(style_type)
	
	# 使用风格的BPM
	bpm = instrument_style.bpm
	
	print("🎹 电子节奏管理器启动（四四拍）")
	print("BPM:", bpm, "，风格:", instrument_style.style_name)
	
	beat_duration = 60.0 / bpm

func _process(delta: float) -> void:
	beat_timer += delta
	
	if beat_timer >= beat_duration:
		beat_timer -= beat_duration
		current_beat += 1
		if current_beat > 4:
			current_beat = 1
		
		on_beat(current_beat)

func on_beat(beat: int):
	# 四四拍：1强，2弱，3中强，4弱
	match beat:
		1:
			play_strong_beat()  # 强拍 - 底鼓
		2, 4:
			process_weak_beat()  # 弱拍 - 军鼓/拍手
		3:
			play_medium_beat()  # 中强拍 - 可选声音

func play_strong_beat():
	# 调用玩家的电子攻击
	var player = get_tree().get_first_node_in_group("player")
	if player and instrument_style:
		instrument_style.play_strong_beat(player)

func play_medium_beat():
	# 中强拍可以播放一些装饰音
	pass

func queue_enemy_death(enemy: Node2D):
	death_queue.append(enemy)

func process_weak_beat():
	var enemy_count = death_queue.size()
	
	if enemy_count > 0:
		# 销毁敌人
		for enemy in death_queue:
			if enemy and enemy.has_method("destroy_on_weak_beat"):
				enemy.destroy_on_weak_beat()
		
		death_queue.clear()
		
		# 播放弱拍声音
		if instrument_style:
			instrument_style.play_weak_beat(self)

func get_style_name() -> String:
	if instrument_style:
		return instrument_style.style_name
	return "未知"
