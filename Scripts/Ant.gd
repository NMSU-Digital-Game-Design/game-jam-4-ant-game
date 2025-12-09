# Ant.gd - FULLY FIXED & OPTIMIZED VERSION
extends CharacterBody2D

enum Team { PLAYER, ENEMY }
@export var team: Team = Team.ENEMY
@export var ant_type: StringName = "melee"  # "melee" or "ranged" later

# Stats
@export var speed: float = 100.0
@export var max_health: float = 50.0
var health: float = max_health
@export var damage: float = 10.0
@export var attack_range: float = 60.0
@export var attack_speed: float = 1.0

@export var projectile_scene: PackedScene  # Optional: preload("res://Scenes/Projectile.tscn")

var direction: float = 1.0
var targets_in_range: Array[Node2D] = []
var attack_timer: float = 0.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/AttackCollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var debug_label: Label = $DebugLabel

func _ready():
	# Set movement direction based on team
	direction = 1.0 if team == Team.PLAYER else -1.0
	
	if team == Team.PLAYER:
		collision_layer = 2	  # I am a Player Ant
		collision_mask  = 4 | 16	  # I only collide with Enemy Ants (layer 4)
	else:
		collision_layer = 4	  # I am an Enemy Ant  
		collision_mask  = 2 | 8	  # I only collide with Player Ants (layer 2) (4)

	# === FIX 2: AttackArea should ONLY detect enemies (no friendly fire detection) ===
	$AttackArea.collision_mask = 4 if team == Team.PLAYER else 2
	# So: Player ants detect only Enemy ants (layer 4), and vice versa

	# Setup attack range
	attack_shape.shape.radius = attack_range
	
	# Connect signals
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_exited)
	
	# Health bar setup
	health_bar.max_value = max_health
	health_bar.value = health
	
	attack_shape.position.x = 127 * direction
	attack_shape.position.y = 0
	# Optional: flip sprite to face correct direction
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = (team == Team.ENEMY)
	
	update_debug_label()

func _physics_process(_delta):
	velocity.x = direction * speed
	move_and_slide()  

func _process(delta):
	attack_timer -= delta
	if attack_timer <= 0 and targets_in_range.size() > 0:
		attack_nearest_target()
		attack_timer = 1.0 / attack_speed

# Now only enemies enter this — thanks to collision mask!
func _on_body_entered(body):
	if body.is_in_group("ant") or body.has_method("get_team"):  # safety
		targets_in_range.append(body)

func _on_body_exited(body):
	targets_in_range.erase(body)

func attack_nearest_target():
	if targets_in_range.is_empty(): return
	
	var nearest = targets_in_range[0]
	for target in targets_in_range:
		if global_position.distance_to(target.global_position) < global_position.distance_to(nearest.global_position):
			nearest = target
	
	if ant_type == "melee":
		nearest.take_damage(damage)
	elif ant_type == "ranged" and projectile_scene:
		_shoot_projectile(nearest.global_position)

func _shoot_projectile(target_pos: Vector2):
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.direction = (target_pos - global_position).normalized() * 300
	proj.damage = damage
	proj.team = team

func take_damage(amount: float):
	health -= amount
	health = max(0, health)
	health_bar.value = health
	update_debug_label()
	
	if health <= 0:
		queue_free()

func get_team() -> Team:
	return team

func update_debug_label():
	if debug_label:
		var team_name = "Player" if team == Team.PLAYER else "Enemy"
		debug_label.text = "%d HP\n%s" % [health, team_name]
