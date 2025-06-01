extends Node2D

@export var speed: float = 150
 
var direction: Vector2
var damage: int = 0
var current_speed: float = 0
var spawn_position : Vector2
var can_warning_hide = false
var did_warning = false

@export var warning_timeout: float = 0.5  

@onready var camera : Camera2D = UTIL.player_ref.get_node('camera')
@onready var collision = $hitbox/collision
@onready var hitbox = $hitbox
@onready var warning_icon: Sprite2D = $warning
@onready var warning_timer: Timer = $warning_timer

func _ready():
	current_speed = speed
	warning_icon.visible = true

func _physics_process(delta):
	current_speed = speed
	position += direction * current_speed * delta
	update_warning_icon()
	if can_warning_hide:
		can_warning_hide = false
		warning_timer.wait_time = 0.5
		warning_timer.start()

func update_warning_icon():
	var screen_size := get_viewport_rect().size
	var cam_pos := camera.global_position
	var half_screen := screen_size / 2
	var screen_rect := Rect2(cam_pos - half_screen, screen_size)

	# Compute direction from camera to spawn
	var dir := (spawn_position - cam_pos).normalized()

	dir.y = 0
	dir = dir.normalized()

	# Find edge position along the horizontal screen axis
	var edge_x = cam_pos.x + dir.x * (half_screen.x)
	
	warning_icon.global_position = Vector2(edge_x, spawn_position.y)
	warning_icon.rotation = dir.angle()

	if not did_warning:
		did_warning = true
		can_warning_hide = true
		
func _on_vision_screen_exited() -> void:
	queue_free()

func _on_warning_timer_timeout() -> void:
	warning_icon.visible = false
