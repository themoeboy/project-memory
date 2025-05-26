extends Node2D

@export var speed: float = 150
 
var direction: Vector2
var damage: int = 0
var current_speed: float = 0

@export var blend_decay_rate: float = 1.5  
@onready var collision = $hitbox/collision
@onready var hitbox = $hitbox

func _ready():
	current_speed = speed

func _physics_process(delta):
	current_speed = speed
	position += direction * current_speed * delta

 
