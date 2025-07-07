extends Node2D

@export var player_scene: PackedScene
@export var chunk_scene: PackedScene
@export var projectile_scene: PackedScene
@export var warning_scene: PackedScene
@export var chunk_length: int = 512
@export var preload_chunks: int = 5
@export var finish_distance: int = 10000
@export var projectile_spawn_distance: float = 300  # How far to the right of player to spawn
@export var projectile_vertical_variance_max: float = 48
@export var projectile_spawn_timer_variance: int = 3
@export var projectile_spawn_timer_min: int = 2

# Children nodes
@onready var projectile_timer = $projectile_timer
@onready var onscreen_layer = $onscreen_layer
@onready var ui_layer = $ui_layer

var player_ref
var last_chunk_x = 0
var chunks = []
var chunk_scenes = []


func _ready():
	for path in UTIL.CHUNK_SCENE_PATHS:
		chunk_scenes.append(load(path))
	for i in range(preload_chunks):
		spawn_chunk(i * chunk_length)
	spawn_player()
	randomize_timer()
	
func _process(_delta):
	UTIL.onscreen_layer_ref = onscreen_layer
	update_ui()
	if player_ref:
		var player_x = player_ref.global_position.x
		if player_x + (preload_chunks * chunk_length) > last_chunk_x and last_chunk_x < finish_distance:
			spawn_chunk(last_chunk_x)
		cleanup_chunks(player_x)


func spawn_chunk(x_pos):
	if chunk_scenes.size() == 0:
		push_error("No chunk scenes loaded!")
		return
	var random_index = randi() % chunk_scenes.size()
	var chunk = chunk_scenes[random_index].instantiate()
	chunk.position = Vector2(x_pos, 0)
	add_child(chunk)
	chunks.append(chunk)
	last_chunk_x += chunk_length

func spawn_player():
	if chunks.size() == 0:
		push_error("No chunks available to spawn player.")
		return

	var first_chunk = chunks[0]
	var spawn_point = first_chunk.get_node_or_null("spawn")
	if not spawn_point:
		push_error("Could not find 'spawn' ")
		return

	player_ref = player_scene.instantiate()
	player_ref.global_position = spawn_point.global_position
	get_tree().get_current_scene().add_child(player_ref)

func cleanup_chunks(player_x):
	for chunk in chunks:
		if chunk != null:
			if chunk.global_position.x + chunk_length < player_x - chunk_length:
				chunk.queue_free()
	chunks = chunks.filter(func(c): return is_instance_valid(c))

func spawn_projectile():
	if not UTIL.player_ref:
		return

	var projectile = projectile_scene.instantiate()
	var warning = warning_scene.instantiate()
	
	var spawn_x = UTIL.player_ref.global_position.x + projectile_spawn_distance
	var spawn_y = UTIL.player_ref.global_position.y + randf_range(-projectile_vertical_variance_max, 0) 
	
	projectile.global_position = Vector2(spawn_x, spawn_y)
	projectile.direction = Vector2.LEFT
	projectile.damage = 10
	
	add_child(projectile) 
	
	warning.spawn_position = Vector2(spawn_x, spawn_y)
	UTIL.onscreen_layer_ref.add_child(warning)

	
func randomize_timer():
	projectile_timer.wait_time = randf_range(projectile_spawn_timer_min, projectile_spawn_timer_min + projectile_spawn_timer_variance) 
	projectile_timer.start()


func _on_projectile_timer_timeout() -> void:
	spawn_projectile()
	randomize_timer()
	pass # Replace with function body.

func update_ui():
	ui_layer.update_money_label()
