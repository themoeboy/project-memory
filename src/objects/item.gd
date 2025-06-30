extends Area2D

@onready var sprite: Sprite2D = $sprite
var item_name: String = "orange"
var item_value: int

const sprite_sheet = preload("res://assets/items/item_spritesheet.png")
const sprite_size = Vector2(16, 16) 

func _ready():
	if item_name != "":
		var item_data = UTIL.all_items[item_name]
		item_value = item_data.value
		sprite.texture = sprite_sheet
		sprite.region_enabled = true
		var region = item_data.region
		sprite.region_rect = Rect2(region.x * sprite_size.x, region.y * sprite_size.y, sprite_size.x, sprite_size.y)
		
func gather():
	if(Input.is_action_pressed("gather")):
		if item_name in UTIL.trending_products_names_array:
			UTIL.money += item_value
			UTIL.player_ref.get_node('effects').show_positive()
			queue_free()
		else:
			UTIL.player_ref.get_node('effects').show_negative()
			queue_free()
