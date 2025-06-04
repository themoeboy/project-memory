extends CanvasLayer

@onready var money_label: Label = $money

func update_money_label():
	money_label.text = str(UTIL.money)
