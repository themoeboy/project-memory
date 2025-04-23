extends Node2D

@export var speed: float = 400
var direction: Vector2
var damage : float = 0

func _physics_process(delta):
	position += direction * speed * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if area.name == 'hitbox' and enemy.has_method("take_damage") and enemy.is_in_group('enemy'):
		enemy.take_damage(damage)
	return
