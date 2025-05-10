extends Node

enum player_state {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	DOUBLE_JUMPING,
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
