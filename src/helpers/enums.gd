extends Node

enum player_state {
	IDLE,
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
