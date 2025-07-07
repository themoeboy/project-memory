extends Control

var item = preload("res://src/ui/trending_item.tscn")
@onready var grid = $grid
@onready var trending_count = UTIL.INITIAL_TRENDING_CNT

func _ready():
	randomize()
	generate_trending_products()
	add_to_grid()
	
func generate_trending_products():
	UTIL.trending_products_names_array.clear()
	var items = UTIL.ALL_ITEMS_ARRAY.duplicate()
	items.shuffle()
	for i in range(min(trending_count, items.size())):
		UTIL.trending_products_names_array.append(items[i])

func add_to_grid():
		for trending_item_name in UTIL.trending_products_names_array:
			var item_instance = item.instantiate()
			item_instance.item_name = trending_item_name
			grid.add_child(item_instance)
