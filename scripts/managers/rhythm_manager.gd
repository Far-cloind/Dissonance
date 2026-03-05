extends Node

# 节奏管理器 - 管理四二拍（2/4拍）的节奏
# 四二拍：每小节2拍，第1拍强拍，第2拍弱拍

@export var bpm: float = 120.0  # 每分钟节拍数

var beat_duration: float = 0.0  # 每拍持续时间（秒）
var beat_timer: float = 0.0
var current_beat: int = 0  # 当前拍子（1或2）

# 弱拍队列 - 存储需要在弱拍销毁的敌人
var death_queue: Array = []

# 乐器风格策略
var instrument_style: InstrumentStyleBase = null

@onready var snare_synth: AudioStreamPlayer = $SnareSynth
@onready var kick_synth: AudioStreamPlayer = $KickSynth
@onready var string_synth: AudioStreamPlayer = $StringSynth

func _ready():
	# 添加到节奏管理器组
	add_to_group("rhythm_manager")
	
	# 创建乐器风格实例
	var style_type = GlobalGameData.selected_style
	instrument_style = StyleFactory.create_style(style_type)
	
	print("当前乐器风格:", instrument_style.style_name)
	print("风格描述:", instrument_style.get_description())
	
	# 计算每拍持续时间
	beat_duration = 60.0 / bpm
	print("节奏管理器启动，四二拍，BPM:", bpm, "，每拍:", beat_duration, "秒")

func _process(delta: float) -> void:
	beat_timer += delta
	
	# 检查是否到了下一拍
	if beat_timer >= beat_duration:
		beat_timer -= beat_duration
		current_beat += 1
		if current_beat > 2:
			current_beat = 1
		
		on_beat(current_beat)

func on_beat(beat: int):
	# 四二拍：第1拍是强拍，第2拍是弱拍
	if beat == 1:
		# 强拍 - 播放底鼓/低音（玩家冲击波）
		play_kick_on_beat()
	elif beat == 2:
		# 弱拍 - 销毁敌人并播放军鼓/高音
		process_weak_beat()

func play_kick_on_beat():
	# 在强拍时触发玩家的底鼓和冲击波
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("play_kick_on_beat"):
		player.play_kick_on_beat()

func queue_enemy_death(enemy: Node2D):
	# 将敌人加入弱拍销毁队列
	death_queue.append(enemy)

func process_weak_beat():
	# 处理弱拍：销毁敌人并播放军鼓/高音
	var enemy_count = death_queue.size()
	
	if enemy_count > 0:
		# 销毁所有队列中的敌人
		for enemy in death_queue:
			if enemy and enemy.has_method("destroy_on_weak_beat"):
				enemy.destroy_on_weak_beat()
		
		# 清空队列
		death_queue.clear()
		
		# 使用策略模式播放弱拍声音
		if instrument_style:
			instrument_style.play_weak_beat(self)
		
		if enemy_count > 1:
			print("弱拍销毁敌人:", enemy_count, "个")
