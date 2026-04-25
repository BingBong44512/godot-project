extends Control

@onready var item_list = $Panel/VBoxContainer/ScrollContainer/ItemList
@onready var close_btn = $Panel/VBoxContainer/CloseButton

func _ready():
	hide()
	_build_shop()
	close_btn.pressed.connect(hide)

func _build_shop():
	for item_name in GodLogic.shop_data:
		var data = GodLogic.shop_data[item_name]
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = "%s ($%d)\n%s" % [item_name.capitalize(), data.price, data.desc]
		label.custom_minimum_size.x = 200
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		
		var buy_btn = Button.new()
		buy_btn.text = "Buy"
		buy_btn.pressed.connect(_on_buy_pressed.bind(item_name))
		
		hbox.add_child(label)
		hbox.add_child(buy_btn)
		item_list.add_child(hbox)

func _on_buy_pressed(item_name):
	var game = get_tree().current_scene
	var price = GodLogic.shop_data[item_name].price
	
	if game and "money" in game and game.money >= price:
		game.money -= price
		GodLogic.inventory[item_name] += 1
		print("Bought ", item_name)
		# Signal the hotbar to update
		get_tree().call_group("hud", "update_inventory")
	else:
		print("Not enough money!")

func toggle():
	visible = !visible
	if visible: _update_buttons()

func _update_buttons():
	# Could disable buttons if money is too low
	pass
