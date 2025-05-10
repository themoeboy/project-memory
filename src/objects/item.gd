extends Area2D

@onready var item_name: String = "lamp"
@onready var sprite: Sprite2D = $sprite

func _ready():
	if item_name != "":
		var path = "res://assets/items/%s.png" % item_name
		var texture = load(path)
		if texture:
			sprite.texture = texture
		else:
			print("❌ Could not load item sprite:", path)

func gather():
	if(Input.is_action_pressed("gather")):
		queue_free()
