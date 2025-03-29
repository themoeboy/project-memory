extends Node

@export var enemy: CharacterBody2D  # Reference to the enemy
@export var movement_pattern: String = "patrol"  # "patrol", "chase", "jump", "fly"
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
		"patrol":
			patrol_behavior(delta)
		"chase":
			chase_behavior(delta)
		"jump":
			jumping_behavior(delta)
		"fly":
			flying_behavior(delta)
		"idle":
			idle_behavior(delta)

func patrol_behavior(delta):
	var distance_from_start = enemy.global_position.x - start_position.x

	print("Current Distance:", distance_from_start)
	print("Patrol Range:", patrol_range)
	
	if distance_from_start == patrol_range:
		direction = 0  # Move left
	# Flip direction when exceeding patrol range
	if distance_from_start >= patrol_range:
		direction = -1  # Move left
	elif distance_from_start <= -patrol_range:
		direction = 1   # Move right

	enemy.ai_direction = direction


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
		movement_pattern = "patrol"  # Resume patrol after idling
		idle_timer = 0.0
