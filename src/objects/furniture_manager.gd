extends Node2D

@export var max_item_count: int = 2
@export var tile_size: int = 16
@export var row: int = 5
@export var col: int = 3
@export var offset: int = 4

var item_scene = preload("res://src/objects/item.tscn")
@onready var instancePos = get_parent().position

func generate_items():
	var available_cells = []
	var item_count = 1 + randi() % max_item_count
	
	# Get top-left offset based on the shelf sprite
	var shelf_origin = Vector2(0,0) # Or use $sprite.position if that's your visual anchor

	# Build all available cell grid positions
	for y in range(row):
		for x in range(col):
			available_cells.append(Vector2(x, y))
	
	available_cells.shuffle()

	for i in range(min(item_count, available_cells.size())):
		var item_instance = item_scene.instantiate()

		var grid_pos = available_cells[i]
		var pos_x = shelf_origin.x + grid_pos.x * tile_size + tile_size/2 + (randi() % offset)
		var pos_y = shelf_origin.y + grid_pos.y * tile_size + tile_size/2 

		item_instance.position = Vector2(pos_x, pos_y)
		
		var random_index = randi() % UTIL.ALL_ITEMS_ARRAY.size()
		item_instance.item_name = UTIL.ALL_ITEMS_ARRAY[random_index]

		add_child(item_instance)
