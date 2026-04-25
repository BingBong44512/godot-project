extends TileMapLayer

var animal = preload("res://scenes/animal.tscn")
var sim_timer: float = 0.0
const SIM_INTERVAL: float = 3.0 # Simulate every 3 seconds

func _ready():
	GodLogic.generate_world(self)

func _process(delta):
	sim_timer += delta
	if sim_timer >= SIM_INTERVAL:
		sim_timer = 0.0
		simulate_grass_life()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = local_to_map(get_local_mouse_position())
		var item = GodLogic.selected_item
		if item == "" or not item in GodLogic.inventory: return
		
		var game = get_tree().current_scene
		if GodLogic.inventory[item] > 0:
			if item == "water":
				GodLogic.watered_tiles[pos] = Time.get_ticks_msec()
				GodLogic.inventory[item] -= 1
				get_tree().call_group("hud", "update_inventory")
				print("Watered tile at ", pos)
				return

			var current_source = get_cell_source_id(pos)
			if current_source == 1: # Already grass
				return

			if item in game:
				game.set(item, game.get(item) + 1)
				GodLogic.inventory[item] -= 1
				set_cell(pos, 1, Vector2i(0, 0)) # Set to Grass (Source 1)
				
				if item != "grass":
					var instance = animal.instantiate()
					instance.animal = item	
					var mouse_pos = get_global_mouse_position()
					instance.position.x =mouse_pos.x+randf()*50
					instance.position.y =mouse_pos.y+randf()*50
					add_child(instance)
				get_tree().call_group("hud", "update_inventory")
		else:
			print("Out of ", item, "!")

func simulate_grass_life():
	var game = get_tree().current_scene
	if not game: return
	
	var tiles_to_die = []
	var used_cells = get_used_cells()
	
	for pos in used_cells:
		if get_cell_source_id(pos) == 1: # If it's Grass
			var neighbors = get_surrounding_cells(pos)
			var grass_neighbors = 0
			for n in neighbors:
				if get_cell_source_id(n) == 1:
					grass_neighbors += 1
			
			var is_edge = grass_neighbors < 4 # Arbitrary edge definition
			
			var is_watered = false
			if GodLogic.watered_tiles.has(pos):
				var watered_at = GodLogic.watered_tiles[pos]
				var now = Time.get_ticks_msec()
				# 5 minutes = 300,000 milliseconds
				if now - watered_at < 300000:
					is_watered = true
				else:
					GodLogic.watered_tiles.erase(pos) # Water expired
			
			# Death conditions:
			# 1. Edge of patch and not watered
			# 2. Too many animals (Overgrazing) - using health as proxy for animal density
			var animal_count = game.toads + game.elk + game.bison + game.snake
			var overgrazed = animal_count > (game.grass * 2) and randf() > 0.5
			
			if (is_edge and not is_watered) or overgrazed:
				tiles_to_die.append(pos)
	
	for pos in tiles_to_die:
		set_cell(pos, 2, Vector2i(1, 0)) # Set to Dead Grass (Source 2, Tile 1,0)
		if "grass" in game:
			game.grass -= 1
		print("Grass died at ", pos)
