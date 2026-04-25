extends Button

signal purchase
signal gambling

@export var options: Array[String] = [] 
@export var cost: int = 10

func _pressed():

	var game = get_tree().current_scene
	if game != null and "money" in game and game.money >= cost:
		game.money -= cost
		var buying = options.pick_random()
		if buying == null:
			print("Error: No options defined in the purchase button!")
			return
			
		gambling.emit(buying)
		purchase.emit(buying)
		# Automatically increment the counter in game_logic if it exists
		if buying in game:
			game.set(buying, game.get(buying) + 1)
		print("Bought: ", buying, " for $", cost)
	else:
		if game == null:
			print("Error: Game scene not found!")
		else:
			print("Not enough money!")
	
