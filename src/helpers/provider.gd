extends Node

# Signal bus
signal show_flair(value: int)

# This is where global data is saved

var flipped_tiles_stack = []
var to_remove_tile 
var tiles_clickable: bool = true
var current_score: int = 0

	
