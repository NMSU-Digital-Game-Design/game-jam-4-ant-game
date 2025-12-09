# ant_spawner.gd
extends Node2D

enum Team { PLAYER, ENEMY }
@export var team: Team = Team.PLAYER

@export var ant_scene: PackedScene = preload("res://Scenes/Ant.tscn")
@export var spawn_interval: float = 3.0
@export var spawn_offset: Vector2 = Vector2(-200, 0)  # Relative to hill
@export var ant_cost: float = 20.0

var anthill: Node2D  # Will reference parent anthill
var timer: Timer

func _ready():
	# Parent MUST be the anthill
	anthill = get_parent()
	if not anthill:
		push_error("AntSpawner must be child of an Anthill!")
		return
	
	# Setup auto-spawn timer (only for AI, or both if desired)
	if team == Team.ENEMY:  # Change later if player shouldn't auto-spawn
		timer = Timer.new()
		timer.wait_time = spawn_interval
		timer.autostart = true
		timer.timeout.connect(_auto_spawn)
		add_child(timer)

func spawn_now():  # Called by UI button (only player)
	_do_spawn()

func _auto_spawn():
	# Optional: Add food cost for AI too, or make AI free
	_do_spawn()

func _do_spawn():
	if not ant_scene:
		push_error("Ant scene not assigned!")
		return
	
	var ant = ant_scene.instantiate()
	ant.team = team
	ant.global_position = global_position + spawn_offset * (1 if team == Team.PLAYER else -1)
	
	# Add to scene tree properly
	get_tree().current_scene.add_child(ant)
	# Or: anthill.get_parent().add_child(ant) if you prefer
