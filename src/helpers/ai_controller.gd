extends Node

@export var enemy: CharacterBody2D  # Reference to the enemy
@export var movement_pattern: int = ENUMS.enemy_behavior.IDLE
@export var patrol_range: float = 200.0
@export var chase_speed: float = 400.0
@export var idle_time: float = 2.0
@export var jump_force: float = -600.0  # Force for jumping enemies
@export var jump_interval: float = 2.0  # Time between jumps
@export var flight_amplitude: float = 50.0  # Height of flying movement
@export var flight_speed: float = 2.0  # Speed of flying motion

var direction = 1
var start_position
var idle_timer = 0.0
var jump_timer = 0.0
var flight_timer = 0.0

func _ready():
	if enemy:
		start_position = enemy.global_position

func _process(delta):
	if not enemy:
		return

	match movement_pattern:
		ENUMS.enemy_behavior.PATROL:
			patrol_behavior(delta)
		ENUMS.enemy_behavior.CHASE:
			chase_behavior(delta)
		ENUMS.enemy_behavior.JUMP:
			jumping_behavior(delta)
		ENUMS.enemy_behavior.FLY:
			flying_behavior(delta)
		ENUMS.enemy_behavior.IDLE:
			idle_behavior(delta)

func patrol_behavior(delta):
	var distance_from_start = enemy.global_position.x - start_position.x
	var reversed = false

	# Stop when reaching patrol limit before reversing
	if abs(distance_from_start) >= patrol_range and !reversed:
		enemy.ai_direction = 0  # Hard stop
		reversed = true
		await get_tree().create_timer(0.5).timeout  # 0.5s pause before reversing
	if reversed and distance_from_start >= patrol_range:
		direction = -1  # Reverse direction
		enemy.ai_direction = direction  # Resume moving
		reversed = false
	elif reversed and distance_from_start <= patrol_range:
		direction = 1  # Reverse direction
		enemy.ai_direction = direction  # Resume moving
		reversed = false


func chase_behavior(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var player_direction = sign(player.global_position.x - enemy.global_position.x)
		enemy.ai_direction = player_direction
		enemy.MAX_SPEED = chase_speed  # Adjust speed dynamically

func jumping_behavior(delta):
	jump_timer += delta
	if jump_timer >= jump_interval and enemy.is_on_floor():
		enemy.velocity.y = jump_force  # Apply jump force
		jump_timer = 0.0  # Reset timer

	# Basic movement
	enemy.ai_direction = direction

func flying_behavior(delta):
	flight_timer += delta
	enemy.velocity.y = sin(flight_timer * flight_speed) * flight_amplitude  # Smooth flying motion
	enemy.ai_direction = direction

func idle_behavior(delta):
	enemy.ai_direction = 0  # Stop movement
	idle_timer += delta
	if idle_timer >= idle_time:
		movement_pattern = ENUMS.enemy_behavior.PATROL  # Resume patrol after idling
		idle_timer = 0.0
