extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0  # 每2秒生成一个敌人
@export var spawn_distance: float = 100.0  # 在屏幕外多远处生成

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		return
	
	# 获取玩家位置
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	# 在屏幕边缘外随机位置生成
	var spawn_position = get_random_spawn_position(player.global_position)
	
	# 实例化敌人
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_parent().add_child(enemy)

func get_random_spawn_position(player_position: Vector2) -> Vector2:
	# 获取视口大小
	var viewport_size = get_viewport_rect().size
	var camera_zoom = Vector2(1.5, 1.5)  # 与玩家摄像机缩放一致
	var visible_size = viewport_size / camera_zoom
	
	# 随机选择一个边（0:上, 1:右, 2:下, 3:左）
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0:  # 上边
			spawn_pos.x = player_position.x + randf_range(-visible_size.x/2, visible_size.x/2)
			spawn_pos.y = player_position.y - visible_size.y/2 - spawn_distance
		1:  # 右边
			spawn_pos.x = player_position.x + visible_size.x/2 + spawn_distance
			spawn_pos.y = player_position.y + randf_range(-visible_size.y/2, visible_size.y/2)
		2:  # 下边
			spawn_pos.x = player_position.x + randf_range(-visible_size.x/2, visible_size.x/2)
			spawn_pos.y = player_position.y + visible_size.y/2 + spawn_distance
		3:  # 左边
			spawn_pos.x = player_position.x - visible_size.x/2 - spawn_distance
			spawn_pos.y = player_position.y + randf_range(-visible_size.y/2, visible_size.y/2)
	
	return spawn_pos
