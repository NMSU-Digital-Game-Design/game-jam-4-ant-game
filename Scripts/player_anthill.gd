# Scripts/AnthillBase.gd
extends StaticBody2D

enum Team { PLAYER, ENEMY }

signal anthill_died(team)


@export var team : Team = Team.PLAYER
@export var max_health : float = 500
@export var food_per_second : float = 5

# ----- Weapon -----
@export var projectile_scene : PackedScene = preload("res://Scenes/Projectile.tscn")
@export var weapon_damage : float = 15
@export var weapon_range : float = 400
@export var weapon_fire_rate : float = 1.2   # shots per second

# ----- Upgrade -----
@export var upgrade_cost : int = 100
@export var upgrade_health_bonus : int = 150
@export var upgrade_damage_bonus : float = 8
@export var upgrade_rate_bonus : float = 0.2
@export var upgrade_food_production: float = 5

# troop costs
@export var ant_cost : int = 20

var health : float
var food : float = 0
var fire_timer : float = 0.0

@onready var weapon_area : Area2D = $WeaponRange
@onready var sprite : Sprite2D = $Sprite2D

var enemies_in_range : Array[Node2D] = []


func _ready():
	health = max_health
	
	var ui = get_node("/root/main/UI")
	
	ui.upgrade_health_button.connect(_on_upgrade_health_button_pressed)
	ui.summon_ant_button.connect(_on_ant_pressed)

	
	
	# Set correct collision layers so only enemy ants trigger body_entered
	collision_layer = 8 if team == Team.PLAYER else 16   # layer 8 = player hill, 16 = enemy hill
	collision_mask  = 4 if team == Team.PLAYER else 2    # detect enemy ants only
	
	# Weapon detection area
	$WeaponRange/CollisionShape2D.shape.radius = weapon_range
	$WeaponRange.collision_mask = 4 if team == Team.PLAYER else 2
	
	weapon_area.body_entered.connect(_on_weapon_range_body_entered)
	weapon_area.body_exited.connect(_on_weapon_range_body_exited)
	
	# UI (only player hill needs it for now)
	if team == Team.PLAYER:
		update_ui()

func _process(delta):
	# Food income
	if team == Team.PLAYER:
		food += food_per_second * delta
		update_ui()
	
	# Weapon
	fire_timer -= delta
	if fire_timer <= 0 and enemies_in_range.size() > 0:
		fire_at_nearest()
		fire_timer = 1.0 / weapon_fire_rate

func fire_at_nearest():
	var nearest = null
	var best_dist = INF
	for e in enemies_in_range:
		var d = global_position.distance_squared_to(e.global_position)
		if d < best_dist:
			best_dist = d
			nearest = e
	if nearest:
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position
		proj.direction = (nearest.global_position - global_position).normalized()
		proj.damage = weapon_damage
		proj.team = team
		proj.collision_mask = 2 + 4

# ---------- Damage & Death ----------
func take_damage(amount : float):
	health -= amount
	health = maxf(0, health)
	if team == Team.PLAYER:
		update_ui()
	if health <= 0:
		die()

func die():
	print("Anthill destroyed! Team: ", "Player" if team == Team.PLAYER else "Enemy")
	anthill_died.emit(team)
	queue_free()

# ---------- Upgrades (Player only) ----------
func upgrade():
	if food < upgrade_cost: return
	food -= upgrade_cost
	max_health += upgrade_health_bonus
	health += upgrade_health_bonus
	weapon_damage += upgrade_damage_bonus
	weapon_fire_rate += upgrade_rate_bonus
	food_per_second += upgrade_food_production
	scale += Vector2(0.03, 0.03)
	if team == Team.PLAYER:
		update_ui()
		
# player ant spawn
func deploy():
	var ant_spawner = get_parent().get_node("AntSpawner")
	
	if food < ant_cost:
		print("Not enough food!")
		return
	food -= ant_cost
	ant_spawner.spawn_now()

# ---------- UI (Player only) ----------
func update_ui():
	var ui = get_node_or_null("/root/main/UI/Panel/Margin/VBox")
	if ui:
		ui.get_node("FoodAmount/Panel/HBox/FoodLabel").text = "" + str(int(food))
		ui.get_node("Health/HealthBar").max_value = max_health
		ui.get_node("Health/HealthBar").value = health
		ui.get_node("Health/HealthBar/HealthLabel").text = "%d / %d" % [health, max_health]

# ---------- Weapon range signals ----------
func _on_weapon_range_body_entered(body):
	if (body.is_in_group("ant") or body.has_method("get_team")) and body.team != team:
		enemies_in_range.append(body)

func _on_weapon_range_body_exited(body):
	enemies_in_range.erase(body)

# ---------- Enemy ants hitting the hill ----------
func _on_body_entered(body):
	if body.is_in_group("ant") and body.team != team:
		take_damage(body.damage)
		body.queue_free()   # ant sacrifices itself when it reaches the hill

# base ant deployment
func _on_ant_pressed() -> void:
	deploy()
# upgrade player base
func _on_upgrade_health_button_pressed() -> void:
	upgrade()
