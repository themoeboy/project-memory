extends Area2D

var hovered = false
signal confirm  

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("confirm") and hovered:
		emit_signal("confirm")
		pass

func _on_mouse_entered() -> void:
	hovered = true
	pass 

func _on_mouse_exited() -> void:
	hovered = false
	pass 
