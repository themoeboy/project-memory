extends Node

# This is where game constants are saved

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

const TILE_SIZE = 32
const SPRITE_SIZE = 16

# Enums

enum player_state {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	DOUBLE_JUMPING,
	PARRYING,
	WALL_SLIDING,
	HURTING,
	THROWING
}

enum enemy_behavior {
	PATROL,
	CHASE,
	JUMP,
	FLY,
	IDLE
}

enum polearm_state {
 	PIERCING,
	PAUSE,
	RETURN
}
