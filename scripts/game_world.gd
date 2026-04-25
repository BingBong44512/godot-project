extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
	generate_wasteland(GameManager.wasteland_size)

func generate_wasteland(size: int) -> void:
	var tile_set = tile_map_layer.tile_set
		
	# Get the first source ID from the TileSet
	var source_count = tile_set.get_source_count()
	
	var source_id = tile_set.get_source_id(0)
	print("Generating wasteland with size: ", size, " using Source ID: ", source_id)
	
	tile_map_layer.clear()
	
	for x in range(-size, size):
		for y in range(-size, size):
			# We use (0,0) as the atlas coordinate for the basic wasteland tile
			tile_map_layer.set_cell(Vector2i(x, y), source_id, Vector2i(0, 0))
