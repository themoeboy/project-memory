extends CharacterBody2D

# Constants
const GRAVITY = 2000.0

const JUMP_FORCE = -500.0
const DASH_SPEED = 400.0

const COYOTE_TIME = 0.2
const JUMP_BUFFER_TIME = 0.1
const DASH_TIME = 0.2
const WALL_SLIDE_SPEED = 100.0

@export var ACCELERATION: float = 100.0
@export var MAX_SPEED: float = 100.0
@export var DEACCELERATION = 1000.0
@onready var ai_controller = $ai_controller  # Reference to AI logic

var ai_direction

func _physics_process(delta):
	if ai_controller:
		ai_direction = ai_controller.direction  # Use AI input

	# Movement handling
	if ai_direction != 0:
		velocity.x = move_toward(velocity.x, ai_direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCELERATION * delta)

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()
