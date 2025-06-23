extends Control

var item = preload("res://src/ui/trending_item.tscn")
@onready var grid = $grid
@export var trending_count = 5

func _ready():
	randomize()
	generate_trending_products()
	add_to_grid()
	
func generate_trending_products():
	UTIL.trending_products_names_array.clear()
	var items = UTIL.all_items_array.duplicate()
	items.shuffle()
	for i in range(min(trending_count, items.size())):
		UTIL.trending_products_names_array.append(items[i])

func add_to_grid():
		for trending_item_name in UTIL.trending_products_names_array:
			var item_instance = item.instantiate()
			item_instance.item_name = trending_item_name
			grid.add_child(item_instance)
