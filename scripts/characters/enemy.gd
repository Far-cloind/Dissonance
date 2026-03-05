extends CharacterBody2D

@export var move_speed: float = 150.0
@export var health: int = 1

var is_dying: bool = false

func _ready():
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	# 追踪玩家
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

func take_damage(damage: int):
	if is_dying:
		return
	
	health -= damage
	print("敌人受到", damage, "点伤害，剩余:", health)
	
	if health <= 0:
		start_death_sequence()

func start_death_sequence():
	is_dying = true
	print("敌人开始死亡序列")
	
	# 停止移动
	velocity = Vector2.ZERO
	
	# 变成粉色
	$Sprite2D.modulate = Color(1, 0.5, 0.8, 1)
	
	# 加入节奏管理器的死亡队列，等待弱拍
	var rhythm_manager = get_tree().get_first_node_in_group("rhythm_manager")
	if rhythm_manager and rhythm_manager.has_method("queue_enemy_death"):
		rhythm_manager.queue_enemy_death(self)
		print("敌人已加入死亡队列，等待弱拍")
	else:
		# 如果没有节奏管理器，直接销毁
		destroy_on_weak_beat()

func destroy_on_weak_beat():
	# 给玩家经验
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("gain_exp"):
		player.gain_exp(10)
	
	print("敌人在弱拍销毁")
	queue_free()

func _on_body_entered(body: Node2D):
	if is_dying:
		return
	
	if body.is_in_group("player"):
		body.take_damage(1)
