extends Node

var player_pos
var polearm_pos
var polearm_paused_pos
var can_dash : bool = false 

func freeze_frame(timescale: float, duration: float ) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true , false , true).timeout
	Engine.time_scale = 1.0
