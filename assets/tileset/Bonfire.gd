extends Area2D





	
func _on_Bonfire_body_entered(body):
	if(body.name == 'Player'):
		MAIN.emit_signal("victory_level")
		
