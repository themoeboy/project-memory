extends Node2D

@onready var positive = $positive
@onready var negative = $negative

func show_positive(duration := 1.0):
	positive.visible = true
	await get_tree().create_timer(duration).timeout
	positive.visible = false

func show_negative(duration := 1.0):
	negative.visible = true
	await get_tree().create_timer(duration).timeout
	negative.visible = false
