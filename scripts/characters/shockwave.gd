extends Area2D

@export var damage: int = 1
@export var max_radius: float = 150.0
@export var expand_speed: float = 300.0
@export var lifetime: float = 0.5

var current_radius: float = 10.0
var hit_enemies: Array[Node] = []

@onready var collision_shape: CircleShape2D = $CollisionShape2D.shape
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# 设置初始大小
	collision_shape.radius = current_radius
	update_visual()
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	
	# 自动销毁
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	# 扩大冲击波范围
	current_radius += expand_speed * delta
	
	if current_radius >= max_radius:
		queue_free()
		return
	
	collision_shape.radius = current_radius
	update_visual()

func update_visual():
	# 更新视觉效果
	if sprite:
		sprite.scale = Vector2(current_radius / 32.0, current_radius / 32.0)

func _on_body_entered(body: Node2D) -> void:
	# 检查是否是敌人
	if body.is_in_group("enemy"):
		# 避免重复伤害
		if body not in hit_enemies:
			hit_enemies.append(body)
			if body.has_method("take_damage"):
				body.take_damage(damage)
