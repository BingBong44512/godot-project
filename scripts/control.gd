extends CanvasLayer

@onready var intro_panel = $Control/IntroPanel
@onready var scale_panel = $Control/ScalePanel
@onready var s = $Control/ScalePanel/PanelContainer/MarginContainer/VBoxContainer/SizeSlider

func _on_next_button_pressed():
	intro_panel.visible = false
	scale_panel.visible = true

func _on_start_button_pressed():
	GodLogic.start_game(int(s.value))
