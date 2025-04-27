extends Node2D

@export var speed: float = 400
@export var recoil_delay: float = 0.2
@export var recoil_speed_multiplier: float = 0.5
@export var deceleration_rate: float = 2000 # how fast it slows down
@export var recoil_acceleration: float = 1000 # how fast it recoils

var direction: Vector2
var damage: float = 0
var hit: bool = false
var recoil_timer: float = 0.0
var current_speed: float = 0.0
var recoiling: bool = false

@onready var collision = $hitbox/collision
@onready var hitbox = $hitbox

func _ready():
	current_speed = speed

func _physics_process(delta):
	if hit:
		recoil_timer -= delta
		if recoil_timer > 0:
			# Gradually decelerate to 0 during recoil delay
			current_speed = max(current_speed - deceleration_rate * delta, 0)
			position += direction * current_speed * delta
		else:
			# After delay, start recoiling backward
			if not recoiling:
				recoiling = true
				current_speed = 0 # make sure it starts from 0

			# Gradually accelerate backward
			current_speed = min(current_speed + recoil_acceleration * delta, speed * recoil_speed_multiplier)
			position -= direction * current_speed * delta
	else:
		position += direction * speed * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if area.name == 'hitbox' and enemy.has_method("take_damage") and enemy.is_in_group('enemy'):
		enemy.take_damage(damage)
		hit = true
		recoil_timer = recoil_delay
		# Properly disable collision detection
		hitbox.set_deferred("monitoring", false)
		collision.set_deferred("disabled", true)
 

func _on_retrievebox_body_entered(body: Node2D) -> void:
	if (body.name == "player" and hit):
		queue_free()
	pass # Replace with function body.
