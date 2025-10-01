extends Node

# Signal bus
signal score_flair(value: int)
signal generate_tiles(row: int, col: int)
signal level_complete()

# This is where global data is saved

var flipped_tiles_stack = []
var to_remove_tile 
var tiles_clickable: bool = true
var current_score: int = 0
var lose_streak = 0 
var win_streak = 0
var current_level: int = 1
    
