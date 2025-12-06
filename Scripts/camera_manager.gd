extends Node2D

var isPressed := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and isPressed:
		global_position -= event.relative
		print(event.relative)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			isPressed = event.pressed
