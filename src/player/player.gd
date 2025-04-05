extends CharacterBody2D

# Constants
@export var GRAVITY = 2000.0
@export var MAX_SPEED = 300.0
@export var JUMP_FORCE = -500.0
@export var DASH_SPEED = 400.0
@export var DASH_DAMAGE = 20
@export var ACCELERATION = 200.0
@export var DEACCELERATION = 1000.0
@export var COYOTE_TIME = 0.2
@export var JUMP_BUFFER_TIME = 0.1
@export var DASH_TIME = 0.2
@export var HURT_TIME = 0.5
@export var WALL_SLIDE_SPEED = 100.0

# States
enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	DOUBLE_JUMPING,
	WALL_SLIDING,
	HURTING
}

# Variables
var current_state = State.IDLE
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_timer = 0.0
var hurt_timer = 0.0
var can_double_jump = true
var is_jumping = false
var is_dashing = false
var is_hurting = false 
var input_direction = 0
var last_direction = 1 


@onready var ray_cast_2d_left = $RayCast2D_left
@onready var ray_cast_2d_right = $RayCast2D_right
@onready var health_component = $health  
@onready var dash_attack_area = $dash_attack # Ensure you have an Area2D node for hit detection
@onready var collision_area = $collision
@onready var hitbox_area = $hitbox

func _ready():
	health_component.health_changed.connect(_on_health_changed)  # Connect signal

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
		State.HURTING:
			handle_hurting(delta)

	# Apply velocity
	move_and_slide()
	handle_direction()
	
	# Determine the next state
	if is_hurting or is_dashing:
		return
	else:
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
	#print("Velocity: ", velocity)
	#print("Coyote Timer: ", coyote_timer)
	#print("Jump Buffer Timer: ", jump_buffer_timer)
	#print("inp dir ", input_direction)
	#print("las dir ", last_direction)
	#print("scale x ", scale.x)
	
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

func handle_hurting(delta):
	handle_input(delta)
	hurt_timer -= delta
	if hurt_timer <= 0:
		is_hurting = false

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
	hitbox_area.monitoring = false  # Be immune to damage on dash
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)
	if dash_timer <= 0:
		hitbox_area.monitoring = true  # Be immune to damage on dash
		dash_attack_area.monitoring = false  # Disable attack after dash ends
		current_state = State.FALLING
		set_collision_layer_value(1, true)  # Disable collision on layer 0
		set_collision_mask_value(2 , true)   # Stop detecting layer 0
		is_dashing = false

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
	input_direction = 0
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
	is_dashing = true
	current_state = State.DASHING
	dash_attack_area.monitoring = true  # Enable attack detection
	dash_timer = DASH_TIME
	velocity.x = last_direction * DASH_SPEED
	

func if_is_on_wall() -> bool:
	return ray_cast_2d_right.is_colliding() or ray_cast_2d_left.is_colliding()
	

func handle_direction():
	if input_direction != 0 and input_direction != last_direction:
		if (input_direction == -1):
			scale.y = -1
			rotation = PI
		elif (input_direction == 1):
			scale.y = 1 
			rotation = 0
		last_direction = input_direction

func _on_health_changed(new_health):
	print("Player health updated:", new_health)

func take_damage(amount: int):
	if !is_hurting:
		is_hurting = true
		current_state = State.HURTING
		health_component.take_damage(amount)  
