extends CanvasLayer

signal upgrade_health_button
signal summon_ant_button

func _ready() -> void:
	# Signals Connections
	$Panel/Margin/VBox/Upgrade/UpgradeHealth.pressed.connect(_on_health_button_pressed)
	$Panel/Margin/VBox/Summon/Button.pressed.connect(_on_summon_button_pressed)
	
	# Progress Bar
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0.75, 0)
	$Panel/Margin/VBox/Health/HealthBar.add_theme_stylebox_override("fill", style)

func _on_health_button_pressed():
	upgrade_health_button.emit()

func _on_summon_button_pressed():
	summon_ant_button.emit()
