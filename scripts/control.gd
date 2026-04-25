extends CanvasLayer
@onready var s = $Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SizeSlider
func _on_start_button_pressed():
	GodLogic.start_game(int(s.value))
