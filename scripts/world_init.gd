extends TileMapLayer

func _ready():
	GodLogic.generate_world(self)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = local_to_map(get_local_mouse_position())
		var current_source = get_cell_source_id(pos)
		
		# source 0 is wasteland, source 1 is grass
		# Don't do anything if it's already grass
		if current_source == 1:
			print("This land is already lush!")
			return

		var item = GodLogic.selected_item
		if item == "" or not item in GodLogic.inventory: return
		
		var game = get_tree().current_scene
		if GodLogic.inventory[item] > 0:
			if item in game:
				# 1. Update populations
				game.set(item, game.get(item) + 1)
				GodLogic.inventory[item] -= 1
				
				# 2. Update visuals (Change to grass tile)
				# set_cell(coords, source_id, atlas_coords)
				set_cell(pos, 1, Vector2i(0, 0))
				
				# 3. Update HUD
				get_tree().call_group("hud", "update_inventory")
				print("Restored tile with ", item, ". Remaining: ", GodLogic.inventory[item])
		else:
			print("Out of ", item, "!")
