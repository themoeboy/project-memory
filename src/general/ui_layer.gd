extends CanvasLayer

@onready var money_label: Label = $money
@onready var trending_products: TextureRect = $trending_products

func update_money_label():
	money_label.text = str(UTIL.money)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		trending_products.visible = not trending_products.visible
