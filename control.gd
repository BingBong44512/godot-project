extends CanvasLayer

@onready var size_slider: HSlider = $Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SizeSlider

func _on_start_button_pressed() -> void:
	# You can use the slider value here to pass to the game scene if needed
	var wasteland_size = size_slider.value
	print("Starting game with size: ", wasteland_size)
	
	# Switch to the game scene
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
