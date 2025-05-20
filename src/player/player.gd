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
@export var DASH_TIME = 0.2
@export var HURT_TIME = 0.5
@export var THROW_TIME = 0.5
@export var WALL_SLIDE_SPEED = 100.0
@export var POLEARM_THROW_DAMAGE = 10.0

# Variables
var current_state = ENUMS.player_state.WALKING
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_timer = 0.0
var pre_dash_velocity = 0
var hurt_timer = 0.0
var throw_timer = 0.0
var can_double_jump = true
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


func _ready():
	health_component.health_changed.connect(_on_health_changed)  
	health_component.now_dead.connect(_on_death)
	
func _physics_process(delta):
	view_items()
	# Update timers
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		can_double_jump = true
	else:
		velocity.y += GRAVITY * delta
		coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# State handling
	match current_state:
		ENUMS.player_state.IDLE:
			handle_idle_state(delta)
		ENUMS.player_state.WALKING:
			handle_walking_state(delta)
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
			animation.play("run")
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
				go_to_state(ENUMS.player_state.IDLE)
		

func handle_walking_state(delta):
	if Input.is_action_just_pressed('run'):
		go_to_state(ENUMS.player_state.RUNNING)
	if Input.is_action_just_pressed('jump'):
		go_to_state(ENUMS.player_state.JUMPING)
	if (velocity.x <= MAX_WALKING_SPEED):
		velocity.x = move_toward(velocity.x, MAX_WALKING_SPEED, WALKING_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, MAX_WALKING_SPEED, WALKING_DEACCELERATION * delta)
	return

func handle_running_state(delta):
	velocity.x = move_toward(velocity.x, MAX_SPEED, RUNNING_ACCELERATION * delta)
	if Input.is_action_just_released('run'):
		go_to_state(ENUMS.player_state.WALKING)
	if Input.is_action_just_pressed('jump'):
		go_to_state(ENUMS.player_state.JUMPING)
	return


func handle_jumping_state(delta):
	if Input.is_action_just_pressed("jump") and can_double_jump:
		go_to_state(ENUMS.player_state.DOUBLE_JUMPING)
		return
	if is_on_floor():
		go_to_state(ENUMS.player_state.WALKING)
		return

func jump():
	velocity.y = JUMP_FORCE

func handle_double_jumping_state(delta):
	handle_jumping_state(delta)

func double_jump():
	velocity.y = JUMP_FORCE
	can_double_jump = false

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
	hurtbox_area.monitoring = false  # Be immune to damage on dash
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)
	
	var polearm_pos = UTIL.polearm_paused_pos if UTIL.polearm_paused_pos != null else UTIL.polearm_pos  
	
	if dash_timer <= 0 or global_position.distance_to(polearm_pos) < 1:
		hurtbox_area.monitoring = true  # Be immune to damage on dash
		dash_attack_area.monitoring = false  # Disable attack after dash ends
		current_state = ENUMS.player_state.IDLE
		set_collision_layer_value(1, true) 
		set_collision_mask_value(2 , true)   
		velocity = Vector2.ZERO
		global_position = polearm_pos



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
		velocity.x = move_toward(velocity.x, input_direction * MAX_SPEED, RUNNING_ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCELERATION * delta)

	# Apply gravity




func dash():
	if(UTIL.can_dash):
		var to_polearm_vec = Vector2(0,0)
		
		if UTIL.polearm_paused_pos:
			to_polearm_vec = UTIL.polearm_paused_pos - global_position
		else:
			to_polearm_vec = UTIL.polearm_pos - global_position
		var distance = to_polearm_vec.length()
		var direction = to_polearm_vec.normalized()

		current_state = ENUMS.player_state.DASHING
		dash_attack_area.monitoring = true
		
		if polearm_instance:
			polearm_instance.queue_free()
			
		velocity = direction * DASH_SPEED
		dash_timer = distance / DASH_SPEED  # Duration needed
		UTIL.can_dash = false
	
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
		hurt_timer = HURT_TIME
		push_character(50)
		UTIL.flash_blinking(sprite, 0.3, 0.1)
		UTIL.freeze_frame(0.2, HURT_TIME)
		current_state = ENUMS.player_state.HURTING
		health_component.take_damage(amount)
	

func shoot_projectile():
	throw_timer = THROW_TIME
	polearm_instance = polearm.instantiate()
	polearm_instance.damage = POLEARM_THROW_DAMAGE
	get_tree().current_scene.add_child(polearm_instance)  

	polearm_instance.global_position = global_position  
	
	var mouse_pos = get_global_mouse_position()
	polearm_instance.direction = (mouse_pos - global_position).normalized()


func _on_gather_area_area_entered(area: Area2D) -> void:
	if area.has_method("gather"):
		area.gather()

func view_items():
	for gatherable in gather_area.get_overlapping_areas():
			if gatherable.has_method('gather') and  Input.is_action_just_pressed("gather"):
					gatherable.gather()
						
