extends Node2D

var dir
var spawn_position


@onready var warning_timer = $warning_timer

func _ready() -> void:
	warning_timer.wait_time = 0.5
	warning_timer.start()
	update_warning_icon()

func _physics_process(delta):
	update_warning_icon()

func update_warning_icon():
	var screen_size := get_viewport_rect().size
	position = Vector2(screen_size.x - 16, spawn_position.y)

func _on_warning_timer_timeout() -> void:
	queue_free()
