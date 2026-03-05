extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var exp_bar: ProgressBar = $ExpBar
@onready var exp_label: Label = $ExpBar/ExpLabel
@onready var time_label: Label = $TimeLabel
@onready var level_label: Label = $LevelLabel

var player: Node2D = null
var game_time: float = 0.0

func _ready():
	# 延迟一帧查找玩家，确保玩家已经初始化
	call_deferred("find_player")

func find_player():
	# 查找玩家
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("UI 找到玩家:", player.name)
		update_health_ui()
		update_exp_ui()
		update_level_ui()
	else:
		print("UI 未找到玩家，将在下一帧重试")
		# 如果还没找到，继续尝试
		call_deferred("find_player")

func _process(delta: float) -> void:
	# 更新游戏时间
	game_time += delta
	update_time_ui()
	
	# 更新玩家状态
	if player != null:
		update_health_ui()
		update_exp_ui()
		update_level_ui()

func update_health_ui():
	if player == null:
		return
	var max_health = player.max_health
	var current_health = player.current_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = "%d/%d" % [current_health, max_health]

func update_exp_ui():
	if player == null:
		return
	var exp_to_level = player.exp_to_next_level
	var current_exp = player.current_exp
	exp_bar.max_value = exp_to_level
	exp_bar.value = current_exp
	exp_label.text = "%d/%d" % [current_exp, exp_to_level]

func update_level_ui():
	if player == null:
		return
	level_label.text = "等级: %d" % player.current_level

func update_time_ui():
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
