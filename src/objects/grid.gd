extends Node2D

@export var tile_size: int = 16
@export var row: int = 5
@export var col: int = 3

var item_scene = preload("res://src/objects/tile.tscn")
@onready var instancePos = self.position

func _ready() -> void:
	generate_items()
	return

func generate_items():
	var available_cells = []
	var offset = Vector2( (row * tile_size) /2 , (col * tile_size)/2)
	var origin = Vector2(0,0) - offset

	for y in range(row):
		for x in range(col):
			available_cells.append(Vector2(x, y))
	
	available_cells.shuffle()

	for i in range(available_cells.size()):
		var item_instance = item_scene.instantiate()

		var grid_pos = available_cells[i]
		var pos_x = origin.x + grid_pos.x * tile_size + tile_size/2 
		var pos_y = origin.y + grid_pos.y * tile_size + tile_size/2 

		item_instance.position = Vector2(pos_x, pos_y)
		
		var random_index = randi() % SCHEMA.ALL_ITEMS_ARRAY.size()
		item_instance.item_name = SCHEMA.ALL_ITEMS_ARRAY[random_index]

		add_child(item_instance)
