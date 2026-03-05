extends CharacterBody2D

@export var move_speed: float = 300.0
@export var max_health: int = 10

var current_health: int

# 经验值系统
var current_exp: int = 0
var current_level: int = 1
var exp_to_next_level: int = 100

# 乐器风格
var instrument_style: InstrumentStyleBase = null

@onready var shockwave_scene: PackedScene = preload("res://scenes/shockwave.tscn")

func _ready():
	add_to_group("player")
	current_health = max_health
	
	# 创建乐器风格实例
	var style_type = GlobalGameData.selected_style
	instrument_style = StyleFactory.create_style(style_type)
	
	print("玩家乐器风格:", instrument_style.style_name)
	print("风格描述:", instrument_style.get_description())

func _physics_process(delta: float) -> void:
	# 玩家移动
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	var distance = global_position.distance_to(mouse_position)
	
	var stop_threshold = 5.0
	if distance > stop_threshold:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	look_at(mouse_position)

# ==================== 摇滚风格攻击 ====================
func play_rock_attack():
	# 摇滚风格：强力冲击波 + 底鼓
	print("🥁 摇滚攻击！")
	
	# 播放底鼓
	var kick_synth = get_node_or_null("KickSynth")
	if kick_synth and kick_synth.has_method("play_kick"):
		kick_synth.play_kick()
	
	# 创建大范围冲击波
	create_shockwave(1.5)  # 1.5倍范围

# ==================== 弦乐风格攻击 ====================
func play_string_attack():
	# 弦乐风格：优雅音波 + 大提琴
	print("🎻 弦乐攻击！")
	
	# 播放大提琴低音
	var string_synth = get_node_or_null("StringSynth")
	if string_synth and string_synth.has_method("play_low_string"):
		string_synth.play_low_string()
	
	# 创建持续音波（可以穿透敌人）
	create_sonic_wave()

# ==================== 电子风格攻击 ====================
func play_electronic_attack():
	# 电子风格：脉冲波 + 合成器低音
	print("🎹 电子攻击！")
	
	# 播放电子低音
	var kick_synth = get_node_or_null("KickSynth")
	if kick_synth and kick_synth.has_method("play_kick"):
		# 可以在这里修改参数实现电子音色
		kick_synth.play_kick()
	
	# 创建快速脉冲波
	create_pulse_wave()

# ==================== 攻击效果创建 ====================
func create_shockwave(scale: float = 1.0):
	var shockwave = shockwave_scene.instantiate()
	shockwave.global_position = global_position
	
	# 缩放冲击波
	if scale != 1.0:
		shockwave.scale = Vector2(scale, scale)
	
	get_parent().add_child(shockwave)

func create_sonic_wave():
	# 弦乐风格：创建可以穿透敌人的音波
	var shockwave = shockwave_scene.instantiate()
	shockwave.global_position = global_position
	
	# 音波特性：持续时间更长，速度更慢
	shockwave.scale = Vector2(0.8, 0.8)
	# 可以在这里设置音波的特殊属性
	
	get_parent().add_child(shockwave)

func create_pulse_wave():
	# 电子风格：创建快速脉冲波
	var shockwave = shockwave_scene.instantiate()
	shockwave.global_position = global_position
	
	# 脉冲特性：速度更快，范围更小
	shockwave.scale = Vector2(0.6, 0.6)
	# 可以在这里设置脉冲的特殊属性
	
	get_parent().add_child(shockwave)

# ==================== 通用方法 ====================
func take_damage(damage: int):
	current_health -= damage
	print("玩家受到", damage, "点伤害，剩余血量:", current_health)
	
	if current_health <= 0:
		die()

func gain_exp(amount: int):
	current_exp += amount
	print("获得", amount, "点经验，当前:", current_exp, "/", exp_to_next_level)
	
	while current_exp >= exp_to_next_level:
		level_up()

func level_up():
	current_exp -= exp_to_next_level
	current_level += 1
	exp_to_next_level = int(exp_to_next_level * 1.5)
	print("升级！当前等级:", current_level)
	
	current_health = min(current_health + 5, max_health)

func die():
	print("玩家死亡！")
	get_tree().reload_current_scene()
