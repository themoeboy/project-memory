extends Node2D

@export var tile_size: int = SCHEMA.TILE_SIZE
@export var tile_gap: int = 8
@export var row: int = 4
@export var col: int = 4

var item_scene = preload("res://src/objects/tile.tscn")

func _ready() -> void:
	generate_items()
	return

func generate_items():
	var available_cells = []
	
	var grid_width = (col * tile_size) + ((col - 1) * tile_gap)
	var grid_height = (row * tile_size) + ((row - 1) * tile_gap)
	
	var screen_size = get_viewport_rect().size
	var origin = Vector2(
		screen_size.x/2 - grid_width/2,
		screen_size.y/2 - grid_height/2
	)

	for y in range(row):
		for x in range(col):
			available_cells.append(Vector2(x, y))
	
	for i in range(available_cells.size()):
		var item_instance = item_scene.instantiate()
		var grid_pos = available_cells[i]
		
		var pos_x = origin.x + (grid_pos.x * (tile_size + tile_gap))
		var pos_y = origin.y + (grid_pos.y * (tile_size + tile_gap))
		
		item_instance.position = Vector2(pos_x, pos_y)
		
		var random_index = randi() % SCHEMA.ALL_ITEMS_ARRAY.size()
		item_instance.item_name = SCHEMA.ALL_ITEMS_ARRAY[random_index]
		
		add_child(item_instance)
