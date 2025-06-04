extends Area2D

@onready var sprite: Sprite2D = $sprite
var item_name: String = "orange"
var item_value: int

func _ready():
	if item_name != "":
		var path = "res://assets/items/%s.png" % item_name
		var texture = load(path)
		item_value = UTIL.all_items[item_name].value
		if texture:
			sprite.texture = texture
		else:
			print("❌ Could not load item sprite:", path)
func gather():
	if(Input.is_action_pressed("gather")):
		UTIL.money = UTIL.money + item_value
		queue_free()
