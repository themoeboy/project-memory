extends Node2D

@export var tile_size: int = SCHEMA.TILE_SIZE
@export var tile_gap: int = 8
@export var row: int = 4
@export var col: int = 4

var item_scene = preload("res://src/objects/tile.tscn")
var can_process: bool = true

func _ready() -> void:
	generate_tiles()
	return

func _process(delta: float):
	if can_process:
		remove_tiles()
	return
	
func remove_tiles():
	if PROVIDER.flipped_tiles_stack.size() == 2:
		can_process = false
		await get_tree().create_timer(0.5).timeout
		
		if PROVIDER.flipped_tiles_stack[0] == PROVIDER.flipped_tiles_stack[1]:
			for child in get_children():
				if child.item_name == PROVIDER.flipped_tiles_stack[0]:
					child.queue_free()
		else:
			for child in get_children():
				if child.is_flipped:
					child.is_flipped = false
		
		PROVIDER.flipped_tiles_stack.clear()
		can_process = true
	return

func generate_tiles():
	var available_cells = []
	var pairs_to_generate = (row * col) / 2
	var selected_items = []
	var used_indices = [] 
	
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
	
	while selected_items.size() < row * col:
		var random_index = randi() % SCHEMA.ALL_ITEMS_ARRAY.size()
		if random_index not in used_indices:
			var item_name = SCHEMA.ALL_ITEMS_ARRAY[random_index]
			selected_items.append(item_name)
			selected_items.append(item_name)
			used_indices.append(random_index)
	
	available_cells.shuffle()
	selected_items.shuffle()
	
	for i in range(available_cells.size()):
		var item_instance = item_scene.instantiate()
		var grid_pos = available_cells[i]
		
		var pos_x = origin.x + (grid_pos.x * (tile_size + tile_gap))
		var pos_y = origin.y + (grid_pos.y * (tile_size + tile_gap))
		
		item_instance.position = Vector2(pos_x, pos_y)
		item_instance.item_name = selected_items[i]
		
		add_child(item_instance)
