extends CharacterBody2D

# Constants
const GRAVITY = 2000.0
const MAX_SPEED = 300.0
const JUMP_FORCE = -500.0
const DASH_SPEED = 400.0
const ACCELERATION = 200.0
const DEACCELERATION = 1000.0
const COYOTE_TIME = 0.2
const JUMP_BUFFER_TIME = 0.1
const DASH_TIME = 0.2
const WALL_SLIDE_SPEED = 100.0

# States
enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	DOUBLE_JUMPING,
	WALL_SLIDING
}

# Variables
var current_state = State.IDLE
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_timer = 0.0
var can_double_jump = true
var is_jumping = false

# RayCast nodes
@onready var ray_cast_2d_left = $RayCast2D_left
@onready var ray_cast_2d_right = $RayCast2D_right

var attack_area: Area2D  # Reference to the attack hitbox

func _ready():
	attack_area = $AttackArea  # Ensure you have an Area2D node for hit detection

# Physics process
func _physics_process(delta):
	# Update timers
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		can_double_jump = true
	else:
		coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# State handling
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
		State.RUNNING:
			handle_running_state(delta)
		State.JUMPING:
			handle_jumping_state(delta)
		State.FALLING:
			handle_falling_state(delta)
		State.DASHING:
			handle_dashing_state(delta)
		State.DOUBLE_JUMPING:
			handle_double_jumping_state(delta)
		State.WALL_SLIDING:
			handle_wall_sliding_state(delta)

	# Apply velocity
	move_and_slide()

	# Determine the next state
	if is_on_floor():
		if abs(velocity.x) > 0:
			current_state = State.RUNNING
		else:
			current_state = State.IDLE
	elif velocity.y < 0:
		current_state = State.JUMPING
	elif velocity.y > 0:
		if is_on_wall():
			current_state = State.WALL_SLIDING
		else:
			current_state = State.FALLING

	# Debugging
	#print("State: ", current_state)
	#print("Velocity: ", velocity)
	#print("Coyote Timer: ", coyote_timer)
	#print("Jump Buffer Timer: ", jump_buffer_timer)

func handle_idle_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0:
		jump()
		jump_buffer_timer = 0
	if Input.is_action_just_pressed("dash"):
		dash()

func handle_running_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0:
		jump()
		jump_buffer_timer = 0
	if Input.is_action_just_pressed("dash"):
		dash()

func handle_jumping_state(delta):
	handle_input(delta)
	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= 0.5
		is_jumping = false
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()

func handle_falling_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()

func handle_dashing_state(delta):
	dash_timer -= delta
	attack_area.monitoring = true  # Enable attack detection
	if dash_timer <= 0:
		attack_area.monitoring = false  # Disable attack after dash ends
		current_state = State.FALLING

func handle_double_jumping_state(delta):
	handle_jumping_state(delta)

func handle_wall_sliding_state(delta):
	if not if_is_on_wall():
		current_state = State.FALLING
		return
	velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	if Input.is_action_just_pressed("jump"):
		double_jump()

func handle_input(delta):
	var input_direction = 0
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# Apply acceleration and deacceleration
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCELERATION * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func jump():
	velocity.y = JUMP_FORCE
	is_jumping = true

func double_jump():
	velocity.y = JUMP_FORCE
	can_double_jump = false
	current_state = State.DOUBLE_JUMPING

func dash():
	dash_timer = DASH_TIME
	var dash_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	velocity.x = dash_direction * DASH_SPEED
	current_state = State.DASHING

func if_is_on_wall() -> bool:
	return ray_cast_2d_right.is_colliding() or ray_cast_2d_left.is_colliding()
	
func move_toward(value: float, target: float, step: float) -> float:
	if value < target:
		return min(value + step, target)
	return max(value - step, target)
