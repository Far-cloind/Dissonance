extends Node

# 弦乐节奏管理器 - 华尔兹三拍子，慢节奏

@export var bpm: float = 90.0

var beat_duration: float = 0.0
var beat_timer: float = 0.0
var current_beat: int = 0  # 1, 2, 3 (华尔兹)

var death_queue: Array = []

var instrument_style: InstrumentStyleBase = null

@onready var string_synth: AudioStreamPlayer = $StringSynth

func _ready():
	add_to_group("rhythm_manager")
	
	# 创建乐器风格实例
	var style_type = GlobalGameData.selected_style
	instrument_style = StyleFactory.create_style(style_type)
	
	# 使用风格的BPM
	bpm = instrument_style.bpm
	
	print("🎻 弦乐节奏管理器启动（华尔兹三拍子）")
	print("BPM:", bpm, "，风格:", instrument_style.style_name)
	
	beat_duration = 60.0 / bpm

func _process(delta: float) -> void:
	beat_timer += delta
	
	if beat_timer >= beat_duration:
		beat_timer -= beat_duration
		current_beat += 1
		if current_beat > 3:
			current_beat = 1
		
		on_beat(current_beat)

func on_beat(beat: int):
	# 华尔兹：1强，2弱，3弱
	match beat:
		1:
			play_strong_beat()  # 强拍 - 大提琴
		2, 3:
			process_weak_beat()  # 弱拍 - 小提琴

func play_strong_beat():
	# 调用玩家的弦乐攻击
	var player = get_tree().get_first_node_in_group("player")
	if player and instrument_style:
		instrument_style.play_strong_beat(player)

func queue_enemy_death(enemy: Node2D):
	# 弦乐风格：敌人在强拍死亡，弱拍播放声音
	death_queue.append(enemy)

func process_weak_beat():
	var enemy_count = death_queue.size()
	
	if enemy_count > 0:
		# 销毁敌人
		for enemy in death_queue:
			if enemy and enemy.has_method("destroy_on_weak_beat"):
				enemy.destroy_on_weak_beat()
		
		death_queue.clear()
		
		# 播放弱拍声音（小提琴）
		if instrument_style:
			instrument_style.play_weak_beat(self)

func get_style_name() -> String:
	if instrument_style:
		return instrument_style.style_name
	return "未知"
