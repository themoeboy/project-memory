extends Node2D

@onready var score_label: Label = $score

func update_score():
	score_label.text = str(PROVIDER.current_score)
	return

func _ready() -> void:
	PROVIDER.current_score = SCHEMA.BASE_SCORE
	update_score()
	pass 

func _process(delta: float) -> void:
	update_score()
	pass
