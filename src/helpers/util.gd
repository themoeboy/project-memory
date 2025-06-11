extends Node
# Globals
var player_pos
var player_ref
var polearm_pos
var polearm_paused_pos
var onscreen_layer_ref
var can_dash : bool = false 
var is_parrying : bool = false

# Constants
const all_items = {
	"orange": {
		"name": "orange",
		"value": 10
	},
	"blueberry": {
		"name": "blueberry",
		"value": 20
	}
}

var all_items_array = all_items.keys()


# Progress
var money = 0 



# Functions 

func freeze_frame(timescale: float, duration: float ) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true , false , true).timeout
	Engine.time_scale = 1.0

func flash_blinking(sprite: Sprite2D, duration := 0.5, blink_rate := 0.1):
	var elapsed_time = 0.0

	while elapsed_time < duration:
		await get_tree().create_timer(blink_rate).timeout
		sprite.visible = not sprite.visible
		elapsed_time += blink_rate

	sprite.visible = true
