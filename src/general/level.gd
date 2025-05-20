extends Node2D

@export var player_scene: PackedScene
@export var chunk_scene: PackedScene
@export var chunk_length: int = 512
@export var preload_chunks: int = 5
@export var finish_distance: int = 10000

var player_ref
var last_chunk_x = 0
var chunks = []

func _ready():
	for i in range(preload_chunks):
		spawn_chunk(i * chunk_length)

	spawn_player()

func _process(_delta):
	if player_ref:
		var player_x = player_ref.global_position.x
		if player_x + (preload_chunks * chunk_length) > last_chunk_x and last_chunk_x < finish_distance:
			spawn_chunk(last_chunk_x)
		cleanup_chunks(player_x)

func spawn_chunk(x_pos):
	var chunk = chunk_scene.instantiate()
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
