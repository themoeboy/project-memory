extends Control

@onready var player_state_label = $player_state_label
@onready var velocity_label = $velocity_label

func _physics_process(delta):
	player_state_label.text = ENUMS.player_state.keys()[get_parent().current_state]
	velocity_label.text = str(UTIL.player_ref.velocity)
