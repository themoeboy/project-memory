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
@export var DAMAGE = 10
@onready var ai_controller = $ai_controller  # Reference to AI logic
@onready var health_component = $health  

var ai_direction = 1 
var last_direction = 1

func _ready():
	health_component.health_changed.connect(_on_health_changed)
	health_component.now_dead.connect(_on_death) 

func _on_health_changed(new_health):
	print("enemy health updated:", new_health)

func take_damage(amount: int):
	health_component.take_damage(amount)  

func _physics_process(delta):
	if ai_direction != 0: 
		velocity.x = move_toward(velocity.x, ai_direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCELERATION * delta)  # Decelerate smoothly
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()
	handle_direction()

func handle_direction():
	if ai_direction != 0 and ai_direction != last_direction:
		if (ai_direction == -1):
			scale.y = -1
			rotation = PI
		elif (ai_direction == 1):
			scale.y = 1 
			rotation = 0
		last_direction = ai_direction

func _on_death():
	queue_free()
