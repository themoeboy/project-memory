extends Node

var player_pos

func freeze_frame(timescale: float, duration: float ) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true , false , true).timeout
	Engine.time_scale = 1.0
