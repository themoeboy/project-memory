extends Node2D

@export var max_health: int = 100
var current_health: int

signal health_changed(new_health)

@onready var test = $test 

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)  # Emit signal when health changes
	
func _physics_process(delta):
	test.text = str(current_health)
