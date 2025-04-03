extends Area2D

@export var DAMAGE = 20

func _on_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		enemy.take_damage(DAMAGE)
