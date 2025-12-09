extends CharacterBody2D

enum Team { PLAYER, ENEMY }
@export var team: Team = Team.ENEMY  # Set on spawn!
@export var ant_type: StringName = "melee"  # "melee" or "ranged" — future enum

# Shared Stats (identical for both sides)
@export var speed: float = 100.0
@export var max_health: float = 50.0
var health: float = max_health
@export var damage: float = 10.0
@export var attack_range: float = 60.0  # Updates AttackCollisionShape2D radius
@export var attack_speed: float = 1.0   # Attacks/sec

@export var projectile_scene: PackedScene  # For ranged: preload("res://projectile.tscn")

var direction: float = 1.0  # Auto-set: +1 (right→enemy hill), -1 (left→player hill)
var targets_in_range: Array[Node2D] = []
var attack_timer: float = 0.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/AttackCollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar  # NEW: Reference to ant's health bar
@onready var debug_label: Label = $DebugLabel     # OPTIONAL: For debugging health/team

func _ready():
	direction = 1.0 if team == Team.PLAYER else -1.0
	attack_shape.shape.radius = attack_range
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_exited)
	
	# NEW: Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = health
	update_debug_label()  # OPTIONAL

func _physics_process(delta):
	velocity.x = direction * speed
	move_and_slide()

func _process(delta):
	attack_timer -= delta
	if attack_timer <= 0 and targets_in_range.size() > 0:
		attack_nearest_target()
		attack_timer = 1.0 / attack_speed

func _on_body_entered(body):
	if _is_enemy(body):
		targets_in_range.append(body)

func _on_body_exited(body):
	targets_in_range.erase(body)

func _is_enemy(body) -> bool:
	if not body.has_method("get_team"): return false
	return body.get_team() != team

func get_team() -> Team:
	return team

func attack_nearest_target():
	if targets_in_range.is_empty(): return
	var nearest = targets_in_range[0]
	for t in targets_in_range:
		if global_position.distance_to(t.global_position) < global_position.distance_to(nearest.global_position):
			nearest = t
	if ant_type == "melee":
		nearest.take_damage(damage)
	elif ant_type == "ranged" and projectile_scene:
		_shoot_projectile(nearest.global_position)

func _shoot_projectile(target_pos: Vector2):
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.direction = (target_pos - global_position).normalized() * 200  # Fast projectile speed
	proj.damage = damage
	proj.team = team  # Proj checks team on hit

# UPDATED: Now updates health bar + clamps health
func take_damage(amount: float):
	health -= amount
	health = clamp(health, 0, max_health)  # Clamp like anthill does
	health_bar.value = health  # NEW: Update bar visually
	update_debug_label()       # OPTIONAL: Update debug text
	if health <= 0:
		queue_free()

# NEW: Helper for debug label (shows health/team — great for tug-of-war testing!)
func update_debug_label():
	if debug_label:
		debug_label.text = "%.0f HP\n%s" % [health, "Player" if team == Team.PLAYER else "Enemy"]
