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

			if item == "grass":
				var current_source = get_cell_source_id(pos)
				if current_source == GodLogic.grass_id: # Already grass
					return
				
				if "grass" in game:
					game.grass += 1
					GodLogic.inventory[item] -= 1
					set_cell(pos, GodLogic.grass_id, Vector2i(0, 0))
					get_tree().call_group("hud", "update_inventory")
				return

			# Handle animals
			if item in game:
				game.set(item, game.get(item) + 1)
				GodLogic.inventory[item] -= 1
				
				if item != "grass" and item != "water":
					var instance = animal.instantiate()
					instance.animal = item	
					var mouse_pos = get_global_mouse_position()
					instance.position.x = mouse_pos.x + randf() * 50 -25
					instance.position.y = mouse_pos.y + randf() * 50 -25
					add_child(instance)
				get_tree().call_group("hud", "update_inventory")
		else:
			print("Out of ", item, "!")

func simulate_grass_life():
	var game = get_tree().current_scene
	if not game: return

	var tiles_to_die = []
	var used_cells = get_used_cells()

	# Calculate weighted grazing load
	var grazing_load = 0.0
	for animal_type in GodLogic.grazing_rates:
		if animal_type in game:
			grazing_load += game.get(animal_type) * GodLogic.grazing_rates[animal_type]

	for pos in used_cells:
		var source_id = get_cell_source_id(pos)

		if source_id == GodLogic.grass_id: # Grass
			var neighbors = get_surrounding_cells(pos)
			var grass_neighbors = 0
			for n in neighbors:
				var neighbor_source = get_cell_source_id(n)
				if neighbor_source == GodLogic.grass_id:
					grass_neighbors += 1
				elif neighbor_source == GodLogic.wasteland_id or neighbor_source == GodLogic.dead_grass_id:
					# Spreading logic
					var n_watered = false
					if GodLogic.watered_tiles.has(n):
						if Time.get_ticks_msec() - GodLogic.watered_tiles[n] < 300000:
							n_watered = true

					var spread_chance = 0.08 if n_watered else 0.01
					if randf() < spread_chance:
						set_cell(n, GodLogic.grass_id, Vector2i(0, 0))
						if "grass" in game:
							game.grass += 1

			var is_edge = grass_neighbors < 3
			var is_watered = false
			if GodLogic.watered_tiles.has(pos):
				var watered_at = GodLogic.watered_tiles[pos]
				if Time.get_ticks_msec() - watered_at < 300000:
					is_watered = true
				else:
					GodLogic.watered_tiles.erase(pos)

			# Overgrazing check
			var overgrazed = grazing_load > (game.grass * 2.5) and randf() > 0.7

			# General survival chance based on water
			var natural_death = randf() < (0.001 if is_watered else 0.01)
			
			if overgrazed or natural_death:
				tiles_to_die.append(pos)
				GodLogic.edge_death_timers.erase(pos)
			elif is_edge and not is_watered:
				if not GodLogic.edge_death_timers.has(pos):
					GodLogic.edge_death_timers[pos] = Time.get_ticks_msec()
				
				# 5 minutes = 300,000 milliseconds
				if Time.get_ticks_msec() - GodLogic.edge_death_timers[pos] >= 300000:
					tiles_to_die.append(pos)
					GodLogic.edge_death_timers.erase(pos)
			else:
				# Reset timer if it's no longer an edge or is now watered
				GodLogic.edge_death_timers.erase(pos)

	for pos in tiles_to_die:
		set_cell(pos, GodLogic.dead_grass_id, Vector2i(0, 0))
		if "grass" in game:
			game.grass -= 1
		print("Grass died at ", pos)
