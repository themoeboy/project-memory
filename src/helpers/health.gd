extends Node2D

@export var max_health: int = 100
var current_health: int

signal health_changed(new_health)
signal now_dead(new_health)

@onready var health_label = $health_label

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if current_health == 0:
		now_dead.emit()
	else:
		health_changed.emit(current_health)  # Emit signal when health changes
	
func _physics_process(delta):
	health_label.text = str(current_health)
