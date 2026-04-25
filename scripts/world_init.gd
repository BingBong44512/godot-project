extends TileMapLayer

func _ready():
	GodLogic.generate_world(self)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var item = GodLogic.selected_item
		if item == "" or not item in GodLogic.inventory: return
		
		var game = get_tree().current_scene
		if GodLogic.inventory[item] > 0:
			if item in game:
				game.set(item, game.get(item) + 1)
				GodLogic.inventory[item] -= 1
				get_tree().call_group("hud", "update_inventory")
				print("Placed ", item, ". Remaining: ", GodLogic.inventory[item])
		else:
			print("Out of ", item, "!")
