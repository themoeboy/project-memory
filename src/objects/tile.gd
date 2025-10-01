extends Node2D

@onready var sprite: Sprite2D = $item_sprite
@onready var background: Sprite2D = $background
@onready var mouse_area: Area2D = $mouse_area

var item_name: String = "orange"
var item_value: int
var is_flipped: bool = false

const sprite_sheet = preload("res://assets/items/item_spritesheet.png")
const flipped_tile_sprite = preload("res://assets/environment/flipped_tile.png")
const unflipped_tile_sprite = preload("res://assets/environment/unflipped_tile.png")

const sprite_size = Vector2(SCHEMA.SPRITE_SIZE, SCHEMA.SPRITE_SIZE) 

func connect_signals():
    mouse_area.connect("confirm", _on_confirmed)
    return

func _ready():
    connect_signals()
    if item_name != "":
        var item_data = SCHEMA.ALL_ITEMS[item_name]
        item_value = item_data.value
        sprite.texture = sprite_sheet
        sprite.region_enabled = true
        var region = item_data.region
        sprite.region_rect = Rect2(region.x * sprite_size.x, region.y * sprite_size.y, sprite_size.x, sprite_size.y)
        
func _process(delta: float):
    if is_flipped:
        background.texture = flipped_tile_sprite
        sprite.visible = true
    else:
        background.texture = unflipped_tile_sprite
        sprite.visible = false
    return
    
func _on_confirmed() -> void:
    if(PROVIDER.tiles_clickable):
        is_flipped = !is_flipped
        AUDIO.play(true, 'confirm')
        PROVIDER.flipped_tiles_stack.append(item_name)
