extends Area2D

func _on_area_entered(area):
	var enemy = area.get_parent()
	var player = get_parent()
	if  enemy.has_method("take_damage") and enemy.is_in_group('enemy'):
		enemy.take_damage(player.DASH_DAMAGE)
		monitoring = false
