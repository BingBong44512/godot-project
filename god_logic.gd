extends Node

var wasteland_size: int = 10

func start_game(size: int):
	wasteland_size = size
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

func generate_world(layer: TileMapLayer):
	if not layer or not layer.tile_set: return
	var sid = layer.tile_set.get_source_id(0)
	layer.clear()
	for x in range(-wasteland_size, wasteland_size):
		for y in range(-wasteland_size, wasteland_size):
			layer.set_cell(Vector2i(x, y), sid, Vector2i(0, 0))
