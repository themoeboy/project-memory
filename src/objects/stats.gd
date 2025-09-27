extends Node2D

@onready var score_label: Label = $score
@onready var flair: Label = $flair

func connect_signals():
	PROVIDER.connect("show_flair", score_flair)
	return

func update_score():
	score_label.text = str(PROVIDER.current_score)
	return

func score_flair(value: int):
	flair.text = str(value)
	flair.visible = true
	if(value > 0):
		flair.label_settings.font_color = SCHEMA.COLOR_SCHEMA.success
	else:
		flair.label_settings.font_color = SCHEMA.COLOR_SCHEMA.fail
	await get_tree().create_timer(0.5).timeout
	flair.visible = false

func _ready() -> void:
	connect_signals()
	PROVIDER.current_score = SCHEMA.BASE_SCORE
	update_score()
	pass 

func _process(delta: float) -> void:
	update_score()
	pass
