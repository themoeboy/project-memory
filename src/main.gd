extends Node


var has_pole = true
var pole_hp 
var player_hp
var can_dash = true
var dead = false 
var success = false 
var paused = false 

var MAX_POLE_HP = 1000
var MAX_PLAYER_HP = 1000
var curr_enemies = 0 

var player = null

var player_hp_decrease_rate = 2.5
var player_hp_decrease_rate_enemy = 200
var player_hp_increase_rate_enemy = 500
var player_hp_increase_rate = 1

var pole_hp_increase_rate = 10
var pole_hp_increase_rate_enemy = 100
var pole_hp_decrease_rate_enemy = 200
var pole_hp_decrease_rate = 10
var player_hp_decrease_rate_enemy_projectile = 10

var clear_time 
var CHARGE_TIME_MAX = 300

var knockback_direction

const ANIM_SPRITE_X_OFFSET = 32.741

var LEVEL_REQ = {
	'Level1': {
		'enemies': 7,
		'time': CHARGE_TIME_MAX,
	},
	'Level2': {
		'enemies': 11,
		'time': CHARGE_TIME_MAX,
	},
	'Level3': {
		'enemies': 11,
		'time': CHARGE_TIME_MAX,
	}
}

var POLE_HP = 1000
var PLAYER_HP = 1000

signal pole_taken_attempt(arg)

signal pole_move_attempt(arg)

signal victory_level()

signal start_timer()

func reset():
 has_pole = true
 pole_hp = POLE_HP
 player_hp = PLAYER_HP
 dead = false
 can_dash = true
 curr_enemies = 0 
 clear_time = 0
 success = false 

func _ready():
 has_pole = true
 pole_hp = POLE_HP
 player_hp = PLAYER_HP
