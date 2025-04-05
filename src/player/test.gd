extends Label

func _physics_process(delta):
	text = get_parent().State.keys()[get_parent().current_state]
	
