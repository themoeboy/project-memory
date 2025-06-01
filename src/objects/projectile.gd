extends Node2D

@export var speed: float = 150
 
var direction: Vector2
var damage: int = 0

@onready var collision = $hitbox/collision
@onready var hitbox = $hitbox


func _physics_process(delta):
	position += direction * speed * delta

func _on_vision_screen_exited() -> void:
	queue_free()
