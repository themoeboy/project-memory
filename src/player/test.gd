extends Label

func _physics_process(delta):
	text = ENUMS.player_state.keys()[get_parent().current_state]
	
