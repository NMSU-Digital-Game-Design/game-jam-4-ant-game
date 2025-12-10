extends CanvasLayer

signal play_again

@onready var color_box = $Panel/ColorRect
@onready var message = $Panel/ColorRect/VBoxContainer/Label
@onready var button = $Panel/ColorRect/VBoxContainer/Button

func _ready():
	button.pressed.connect(_on_play_again)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 1, 0)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	color_box.add_theme_stylebox_override("panel", style)

func show_win():
	message.text = "You Won \\o/"
	color_box.color = Color(0,1,0, 0.5)
	show()

func show_loss():
	message.text = "You Lost :("
	color_box.color = Color(1,0,0, 0.5)
	show()

func _on_play_again():
	play_again.emit()
