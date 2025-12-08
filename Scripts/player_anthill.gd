extends Area2D

# --- Anthill Stats ---
@export var max_health = 100
var health = max_health
var food = 0
@export var food_per_second = 5

# --- UI References ---
@onready var health_bar = $"/root/main/UI/HealthBar"
@onready var food_label = $"/root/main/UI/FoodLabel"
@onready var upgrade_health_button = $"/root/main/UI/UpgradeHealthButton"
@onready var health_label = $"/root/main/UI/HealthLabel"

# --- Upgrade Settings ---
@export var upgrade_cost = 100
@export var upgrade_health_increase = 50
@export var upgrade_scale_increase = Vector2(0.01, 0.01)  # bigger increment for visibility
@onready var sprite = $Sprite2D

func _ready():
	set_process(true)

	# For testing, start with enough food to upgrade
	food = 200

	# Initialize UI
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if food_label:
		food_label.text = "Food: " + str(floor(food))
	
	if sprite and sprite.texture:
		var tex_size = sprite.texture.get_size()
		var bottom_center = Vector2(tex_size.x / 2, tex_size.y)  # local coords

		# Move the sprite up so its bottom aligns with Area2D origin
		sprite.position = -bottom_center
		sprite.centered = true  # you can keep it centered now, looks cleaner

		# Optional: if your collision shape is a child, move it too!
		if has_node("CollisionShape2D"):
			$CollisionShape2D.position = -bottom_center
	
	# Connect the upgrade button dynamically 
	if upgrade_health_button:
		var callback = Callable(self, "_on_upgrade_health_pressed")
		if not upgrade_health_button.is_connected("pressed", callback):
			upgrade_health_button.pressed.connect(callback)
		print("Upgrade button connected!")
	else:
		print("Upgrade button NOT assigned!")


func _process(delta):
	# Increase food over time
	food += food_per_second * delta
	if food_label:
		food_label.text = "Food: " + str(floor(food))

	# Clamp health and update health bar
	health = clamp(health, 0, max_health)
	if health_bar:
		health_bar.value = health
	
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]

	# Check death
	if health <= 0:
		_die()

func _on_body_entered(body):
	if body.is_in_group("enemy_ant"):
		take_damage(10)
		body.queue_free()

func take_damage(amount):
	health -= amount
	health = clamp(health, 0, max_health)
	if health_bar:
		health_bar.value = health
	print("Anthill health:", health)

# --- Upgrade Anthill ---
func _on_upgrade_health_pressed():
	print("Upgrade button clicked! Food:", food)
	if food >= upgrade_cost:
		print("Enough food to upgrade!")
		food -= upgrade_cost
		food_per_second += 1
		max_health += upgrade_health_increase
		health += upgrade_health_increase
		scale += upgrade_scale_increase  # visually make anthill bigger
		if health_bar:
			health_bar.max_value = max_health
			health_bar.value = health
		if food_label:
			food_label.text = "Food: " + str(floor(food))
		print("Anthill upgraded! Max health:", max_health)
	else:
		print("Not enough food to upgrade!")

func _die():
	print("Anthill destroyed! Game Over.")
	queue_free()
