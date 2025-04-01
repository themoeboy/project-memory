extends Area2D

func _on_area_entered(enemy):
	if enemy.has_method("take_damage"):
		enemy.take_damage(10)  
