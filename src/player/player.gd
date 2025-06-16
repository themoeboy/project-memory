extends CharacterBody2D

# Constants
@export var GRAVITY = 2000.0
@export var MAX_SPEED = 200.0
@export var MAX_WALKING_SPEED = 50.0
@export var WALKING_ACCELERATION = 50.0
@export var WALKING_DEACCELERATION = 100.0
@export var RUNNING_ACCELERATION = 50.0
@export var JUMP_FORCE = -500.0
@export var DASH_SPEED = 400.0
@export var DASH_DAMAGE = 20
@export var DEACCELERATION = 1000.0
@export var COYOTE_TIME = 0.2
@export var JUMP_BUFFER_TIME = 0.1
@export var PARRY_TIME = 0.5
@export var DASH_TIME = 0.2
@export var HURT_TIME = 0.5
@export var THROW_TIME = 0.5
@export var WALL_SLIDE_SPEED = 100.0
@export var POLEARM_THROW_DAMAGE = 10.0

# Variables
var current_state = ENUMS.player_state.WALKING
var previous_state
var current_gravity = GRAVITY
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_timer = 0.0
var pre_dash_velocity = 0
var hurt_timer = 0.0
var throw_timer = 0.0
var can_double_jump = true
var can_jump_from_parry = false
var input_direction = 0
var last_direction = 1
var polearm_instance

@onready var ray_cast_2d_left = $RayCast2D_left
@onready var ray_cast_2d_right = $RayCast2D_right
@onready var health_component = $health  
@onready var dash_attack_area = $dash_attack 
@onready var collision_area = $collision
@onready var hurtbox_area = $hurtbox
@onready var polearm = preload("res://src/player/polearm.tscn")
@onready var animation = $animation
@onready var sprite = $sprite
@onready var gather_area = $gather_area
@onready var parry_timer = $parry_timer
@onready var parry_area = $parry_area

func _ready():
	health_component.health_changed.connect(_on_health_changed)  
	health_component.now_dead.connect(_on_death)
	go_to_state(ENUMS.player_state.WALKING)
	current_gravity = GRAVITY
	
func _physics_process(delta):
	view_items()
	# Update timers
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		can_double_jump = true
	else:
		velocity.y += current_gravity * delta
		coyote_timer -= delta
		
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# State handling
	match current_state:
		ENUMS.player_state.WALKING:
			handle_walking_state(delta)
		ENUMS.player_state.RUNNING:
			handle_running_state(delta)
		ENUMS.player_state.JUMPING:
			handle_jumping_state(delta)
		ENUMS.player_state.PARRYING:
			handle_parrying_state(delta)
		ENUMS.player_state.DOUBLE_JUMPING:
			handle_double_jumping_state(delta)
		ENUMS.player_state.FALLING:
			handle_falling_state(delta)
		ENUMS.player_state.HURTING:
			handle_hurting(delta)

	# Apply velocity
	move_and_slide()
	handle_direction()
	
	#Update Globals
	UTIL.player_pos = position
	UTIL.player_ref = self
	
	# Debugging
	#print("Velocity: ", velocity)
	#print("Coyote Timer: ", coyote_timer)
	#print("Jump Buffer Timer: ", jump_buffer_timer)
	#print("inp dir ", input_direction)
	#print("las dir ", last_direction)
	#print("scale x ", scale.x)
	
func go_to_state(state):
	match state:
		ENUMS.player_state.RUNNING:
			current_state = ENUMS.player_state.RUNNING
			animation.play("walk")
		ENUMS.player_state.WALKING:
			current_state = ENUMS.player_state.WALKING
			animation.play("walk")
		ENUMS.player_state.JUMPING:
			jump_buffer_timer = JUMP_BUFFER_TIME
			jump()
			current_state = ENUMS.player_state.JUMPING
			animation.play("jump")
		ENUMS.player_state.DOUBLE_JUMPING:
			double_jump()
			current_state = ENUMS.player_state.DOUBLE_JUMPING
		ENUMS.player_state.HURTING:
			current_state = ENUMS.player_state.HURTING
		ENUMS.player_state.PARRYING:
			animation.play("parry")
			UTIL.is_parrying = true
			parry_timer.wait_time = PARRY_TIME
			parry_timer.start()
			current_state = ENUMS.player_state.PARRYING
		ENUMS.player_state.FALLING:
			animation.play("parry")
			current_state = ENUMS.player_state.FALLING
		
	
func handle_walking_state(delta):
	current_gravity = GRAVITY
	if Input.is_action_just_pressed('run'):
		go_to_state(ENUMS.player_state.RUNNING)
	if Input.is_action_just_pressed('jump'):
		go_to_state(ENUMS.player_state.JUMPING)
	if Input.is_action_just_pressed('parry'):
		go_to_state(ENUMS.player_state.PARRYING)
	if (velocity.x <= MAX_WALKING_SPEED):
		velocity.x = move_toward(velocity.x, MAX_WALKING_SPEED, WALKING_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, MAX_WALKING_SPEED, WALKING_DEACCELERATION * delta)
	return

func handle_running_state(delta):
	current_gravity = GRAVITY
	velocity.x = move_toward(velocity.x, MAX_SPEED, RUNNING_ACCELERATION * delta)
	if Input.is_action_just_released('run'):
		go_to_state(ENUMS.player_state.WALKING)
	if Input.is_action_just_pressed('jump'):
		go_to_state(ENUMS.player_state.JUMPING)
	if Input.is_action_just_pressed('parry'):
		go_to_state(ENUMS.player_state.PARRYING)
	return

func handle_jumping_state(delta):
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()
		go_to_state(ENUMS.player_state.DOUBLE_JUMPING)
		return
	if Input.is_action_just_pressed('parry'):
		go_to_state(ENUMS.player_state.PARRYING)
	if is_on_floor():
		go_to_state(ENUMS.player_state.WALKING)
		return
	elif not is_on_floor() and velocity.y > 0 and current_state != ENUMS.player_state.FALLING:
		go_to_state(ENUMS.player_state.FALLING)
		return

func handle_falling_state(delta):
	current_gravity = GRAVITY/3
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()
		go_to_state(ENUMS.player_state.DOUBLE_JUMPING)
	if Input.is_action_just_pressed('parry'):
		go_to_state(ENUMS.player_state.PARRYING)
	if is_on_floor():
		if abs(velocity.x) > 0:
			go_to_state(ENUMS.player_state.WALKING)

func handle_double_jumping_state(delta):
	handle_jumping_state(delta)

func handle_parrying_state(delta):
	if UTIL.is_parrying:
		current_gravity = GRAVITY
		velocity.x = last_direction * MAX_WALKING_SPEED
		velocity.y = 0
		hurtbox_area.monitoring = false
		parry_area.monitoring = true
		parry_items()
		if Input.is_action_just_pressed("jump") and can_jump_from_parry:
			go_to_state(ENUMS.player_state.JUMPING)
			can_jump_from_parry = false

func handle_hurting(delta):
	hurt_timer -= delta
	if hurt_timer <= 0: 
		go_to_state(ENUMS.player_state.WALKING)

func jump():
	velocity.y = JUMP_FORCE

func double_jump():
	current_gravity = GRAVITY
	velocity.y = JUMP_FORCE
	can_double_jump = false

func handle_direction():
	if input_direction != 0 and input_direction != last_direction:
		if (input_direction == -1):
			scale.y = -1
			rotation = PI
		elif (input_direction == 1):
			scale.y = 1 
			rotation = 0
		last_direction = input_direction

func push_character(x: int):
	velocity.x = last_direction * x

func _on_health_changed(new_health):
	print("Player health updated:", new_health)

func _on_death():
	print("Player dead")

func take_damage(amount: int):
	if current_state != ENUMS.player_state.HURTING:
		go_to_state(ENUMS.player_state.HURTING)
		hurt_timer = HURT_TIME
		push_character(50)
		UTIL.flash_blinking(sprite, 0.3, 0.1)
		UTIL.freeze_frame(0.2, HURT_TIME)		
		health_component.take_damage(amount)
	
func view_items():
	for gatherable in gather_area.get_overlapping_areas():
			if gatherable.has_method('gather') and  Input.is_action_just_pressed("gather"):
					gatherable.gather()
func parry_items():
	for parryable in parry_area.get_overlapping_areas():
			var projectile = parryable.get_parent()
			if projectile.has_method('parry'):
				projectile.parry()
				can_jump_from_parry = true
						
func _on_parry_timer_timeout() -> void:
	UTIL.is_parrying = false
	parry_area.monitoring = false
	hurtbox_area.monitoring = true
	if is_on_floor():
		if abs(velocity.x) > MAX_WALKING_SPEED:
			go_to_state(ENUMS.player_state.RUNNING)
		else:
			go_to_state(ENUMS.player_state.WALKING)
	else: 
		go_to_state(ENUMS.player_state.FALLING)
	pass 
