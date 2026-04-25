extends Node

var wasteland_size: int = 10
var selected_item: String = "grass"

var inventory = {
	"grass": 0, "toad": 0, "elk": 0, "moose": 0, 
	"snake": 0, "eagle": 0, "owl": 0, "bear": 0, "wolf": 0, "water":0
}

var watered_tiles = {} # Dictionary of Vector2i -> int (timestamp in msec)
var edge_death_timers = {} # Dictionary of Vector2i -> int (timestamp in msec)

var grazing_rates = {
	"toad": 0.25,
	"elk": 2.0,
	"moose": 3.0,
	"snake": 1.0, # Vegetarian snakes
	"eagle": 0.0,
	"owl": 0.0,
	"bear": 0.8,
	"wolf": 0.0
}

var shop_data = {
	"grass": {"price": 10, "desc": "Basic vegetation to start the ecosystem."},
	"water": {"price": 2, "desc": "Hydrates the land. Prevents grass from dying at the edges."},
	"toad": {"price": 5, "desc": "Small amphibians. Good for insect control."},
	"elk": {"price": 35, "desc": "Majestic herbivores that graze the plains."},
	"moose": {"price": 50, "desc": "Tough grazers that can handle harsh lands."},
	"snake": {"price": 10, "desc": "Silent hunters of the undergrowth."},
	"eagle": {"price": 35, "desc": "Apex predators of the skies."},
	"owl": {"price": 20, "desc": "Nighttime hunters with keen eyes."},
	"bear": {"price": 50, "desc": "Powerful omnivores that rule the forest."},
	"wolf": {"price": 25, "desc": "Pack hunters that keep populations in check."}
}

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
