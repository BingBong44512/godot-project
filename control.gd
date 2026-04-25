extends CanvasLayer

@onready var size_slider: HSlider = $Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SizeSlider

func _on_start_button_pressed() -> void:
	# Save the size to the global GameManager
	GameManager.wasteland_size = int(size_slider.value)
	print("Starting game with size: ", GameManager.wasteland_size)
	
	# Switch to the game scene
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
