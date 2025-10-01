extends Node2D

func connect_signals():
    PROVIDER.connect('level_complete', level_complete)
    return

func level_complete():
    PROVIDER.current_level = PROVIDER.current_level + 1
    generate_board()
    return

func generate_board():
    var row = 2
    var col = 2 + floor(PROVIDER.current_level/2)
    
    PROVIDER.emit_signal("generate_tiles", row, col)
    return

func _ready() -> void:
    connect_signals()
    generate_board()
    pass 

func _process(delta: float) -> void:
    pass
