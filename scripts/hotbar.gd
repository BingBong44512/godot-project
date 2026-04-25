extends HBoxContainer

var items = ["grass", "toad", "elk", "moose", "snake", "eagle", "owl", "bear", "wolf"]
var selected = 0

func _ready():
	add_to_group("hud")
	for i in range(items.size()):
		var btn = Button.new()
		btn.text = items[i]
		btn.pressed.connect(_on_item_pressed.bind(i))
		add_child(btn)
	update_inventory()
	_update_selection()

func _on_item_pressed(index):
	selected = index
	GodLogic.selected_item = items[selected]
	_update_selection()

func _update_selection():
	for i in range(get_child_count()):
		get_child(i).modulate = Color.GREEN if i == selected else Color.WHITE

func update_inventory():
	for i in range(items.size()):
		var item_name = items[i]
		var count = GodLogic.inventory[item_name]
		var btn = get_child(i)
		btn.text = "%s (%d)" % [item_name.capitalize(), count]
