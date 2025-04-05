extends Area2D

func _on_area_entered(area):
	var parent = get_parent()
	var enemy = area.get_parent()
	if area.name == 'attack' and parent.has_method("take_damage"):
		parent.take_damage(enemy.DAMAGE)
