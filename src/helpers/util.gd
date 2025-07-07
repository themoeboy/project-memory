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
const ALL_ITEMS = {
	"orange": {
		"name": "orange",
		"value": 10,
		"region": Vector2(0, 0) 
	},
	"blueberry": {
		"name": "blueberry",
		"value": 20,
		"region": Vector2(1, 0) 
	},
	"greenberry": {
		"name": "greenberry",
		"value": 20,
		"region": Vector2(2, 0) 
	},
	"orangeberry": {
		"name": "orangeberry",
		"value": 20,
		"region": Vector2(3, 0) 
	},
	"aquaberry": {
		"name": "aquaberry",
		"value": 20,
		"region": Vector2(4, 0) 
	},
	"game_console_1": {
		"name": "game_console_1",
		"value": 20,
		"region": Vector2(0, 1) 
	},
	"game_console_2": {
		"name": "game_console_2",
		"value": 20,
		"region": Vector2(1, 1) 
	},
	"game_console_3": {
		"name": "game_console_3",
		"value": 20,
		"region": Vector2(2, 1) 
	},
	"game_console_4": {
		"name": "game_console_4",
		"value": 20,
		"region": Vector2(3, 1) 
	},
	"game_console_5": {
		"name": "game_console_5",
		"value": 20,
		"region": Vector2(4, 1) 
	}
}

var ALL_ITEMS_ARRAY = ALL_ITEMS.keys()

var INITIAL_TRENDING_CNT = 4

const CHUNK_COUNT = 2
const CHUNK_WORLD = "first"

func get_chunk_scene_paths() -> Array:
	var arr = []
	for i in CHUNK_COUNT:
		arr.append("res://src/general/chunks/%s_level_chunk_%d.tscn" % [CHUNK_WORLD, i + 1])
	return arr

var CHUNK_SCENE_PATHS = get_chunk_scene_paths()

# Progress
var money = 0 
var trending_products_names_array : Array = []


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
