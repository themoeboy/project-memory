extends CharacterBody2D

# Constants
@export var GRAVITY = 2000.0
@export var MAX_SPEED = 150.0
@export var JUMP_FORCE = -500.0
@export var DASH_SPEED = 400.0
@export var DASH_DAMAGE = 20
@export var ACCELERATION = 200.0
@export var DEACCELERATION = 1000.0
@export var COYOTE_TIME = 0.2
@export var JUMP_BUFFER_TIME = 0.1
@export var DASH_TIME = 0.2
@export var HURT_TIME = 0.5
@export var THROW_TIME = 0.5
@export var WALL_SLIDE_SPEED = 100.0
@export var POLEARM_THROW_DAMAGE = 10.0

# Variables
var current_state = ENUMS.player_state.IDLE
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_timer = 0.0
var pre_dash_velocity = 0
var hurt_timer = 0.0
var throw_timer = 0.0
var can_double_jump = true
var input_direction = 0
var last_direction = 1 


@onready var ray_cast_2d_left = $RayCast2D_left
@onready var ray_cast_2d_right = $RayCast2D_right
@onready var health_component = $health  
@onready var dash_attack_area = $dash_attack 
@onready var collision_area = $collision
@onready var hitbox_area = $hitbox
@onready var polearm = preload("res://src/player/polearm.tscn")

func _ready():
	health_component.health_changed.connect(_on_health_changed)  
	health_component.now_dead.connect(_on_death) 
	
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
		ENUMS.player_state.IDLE:
			handle_idle_state(delta)
		ENUMS.player_state.RUNNING:
			handle_running_state(delta)
		ENUMS.player_state.JUMPING:
			handle_jumping_state(delta)
		ENUMS.player_state.FALLING:
			handle_falling_state(delta)
		ENUMS.player_state.DASHING:
			handle_dashing_state(delta)
		ENUMS.player_state.DOUBLE_JUMPING:
			handle_double_jumping_state(delta)
		ENUMS.player_state.WALL_SLIDING:
			handle_wall_sliding_state(delta)
		ENUMS.player_state.HURTING:
			handle_hurting(delta)
		ENUMS.player_state.THROWING:
			handle_throwing_state(delta)

	# Apply velocity
	move_and_slide()
	handle_direction()
	
	# Debugging
	#print("Velocity: ", velocity)
	#print("Coyote Timer: ", coyote_timer)
	#print("Jump Buffer Timer: ", jump_buffer_timer)
	#print("inp dir ", input_direction)
	#print("las dir ", last_direction)
	#print("scale x ", scale.x)
	
func handle_idle_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed('throw'):
		current_state = ENUMS.player_state.THROWING
		shoot_projectile()
		return
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0:
		jump() 
		jump_buffer_timer = 0
		return
	if Input.is_action_just_pressed("dash"):
		dash()
		return
	if is_on_floor():
			if abs(velocity.x) > 0:
				current_state = ENUMS.player_state.RUNNING
			else:
				current_state = ENUMS.player_state.IDLE
		

func handle_running_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed('throw'):
		current_state = ENUMS.player_state.THROWING
		shoot_projectile()
		return
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0:
		jump()
		jump_buffer_timer = 0
		return
	if Input.is_action_just_pressed("dash"):
		dash()
		return
	if is_on_floor():
			if abs(velocity.x) > 0:
				current_state = ENUMS.player_state.RUNNING
			else:
				current_state = ENUMS.player_state.IDLE

func handle_hurting(delta):
	handle_input(delta)
	hurt_timer -= delta
	if hurt_timer <= 0:
		current_state = ENUMS.player_state.IDLE

func handle_throwing_state(delta):
	velocity.x = 0
	throw_timer -= delta
	if throw_timer <= 0:
		current_state = ENUMS.player_state.IDLE

func handle_jumping_state(delta):
	handle_input(delta)
	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= 0.5
	if Input.is_action_just_pressed("dash"):
		dash()
		return
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()
		return
	if is_on_floor():
		if abs(velocity.x) > 0:
			current_state = ENUMS.player_state.RUNNING
		else:
			current_state = ENUMS.player_state.IDLE
	if velocity.y > 0:
		current_state = ENUMS.player_state.FALLING


func handle_falling_state(delta):
	handle_input(delta)
	if Input.is_action_just_pressed("dash"):
		dash()
	if Input.is_action_just_pressed("jump") and can_double_jump:
		double_jump()
	if is_on_floor():
		if abs(velocity.x) > 0:
			current_state = ENUMS.player_state.RUNNING
		else:
			current_state = ENUMS.player_state.IDLE

func handle_dashing_state(delta):
	dash_timer -= delta
	hitbox_area.monitoring = false  # Be immune to damage on dash
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)

	if dash_timer <= 0:
		hitbox_area.monitoring = true  # Be immune to damage on dash
		dash_attack_area.monitoring = false  # Disable attack after dash ends
		current_state = ENUMS.player_state.IDLE
		set_collision_layer_value(1, true)  # Disable collision on layer 0
		set_collision_mask_value(2 , true)   # Stop detecting layer 0
		velocity.x = pre_dash_velocity

func handle_double_jumping_state(delta):
	handle_jumping_state(delta)

func handle_wall_sliding_state(delta):
	velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	if Input.is_action_just_pressed("jump"):
		double_jump()

func handle_input(delta):
	input_direction = 0
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# If input direction is opposite to movement, stop immediately
	if input_direction != 0 and sign(velocity.x) != input_direction and velocity.x != 0:
		velocity.x = 0
	# Otherwise apply normal acceleration/deceleration
	elif input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCELERATION * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func jump():
	current_state = ENUMS.player_state.JUMPING
	velocity.y = JUMP_FORCE


func double_jump():
	velocity.y = JUMP_FORCE
	can_double_jump = false
	current_state = ENUMS.player_state.DOUBLE_JUMPING

func dash():
	pre_dash_velocity = velocity.x
	current_state = ENUMS.player_state.DASHING
	dash_attack_area.monitoring = true  # Enable attack detection
	dash_timer = DASH_TIME
	velocity.x = last_direction * DASH_SPEED

	
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
	print(last_direction)
	velocity.x = last_direction * x

func _on_health_changed(new_health):
	print("Player health updated:", new_health)

func _on_death():
	print("Player dead")

func take_damage(amount: int):
	if current_state != ENUMS.player_state.HURTING:
		hurt_timer = HURT_TIME
		push_character(50)
		UTIL.freeze_frame(0.2, HURT_TIME)
		current_state = ENUMS.player_state.HURTING
		health_component.take_damage(amount)
		

func shoot_projectile():
	throw_timer = THROW_TIME
	var polearm_instance = polearm.instantiate()
	polearm_instance.damage = POLEARM_THROW_DAMAGE
	get_tree().current_scene.add_child(polearm_instance)  

	polearm_instance.global_position = global_position  
	
	var mouse_pos = get_global_mouse_position()
	polearm_instance.direction = (mouse_pos - global_position).normalized()
