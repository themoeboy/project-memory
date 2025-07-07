extends Node2D

@onready var furniture_manager = $furniture_manager

func _ready():
	randomize()
	furniture_manager.generate_items()
