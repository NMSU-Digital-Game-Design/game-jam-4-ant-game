extends Node2D

enum Team { PLAYER, ENEMY }
@export var team: Team
@export var ant_scene: PackedScene = preload("res://Scenes/Ant.tscn")
@export var spawn_interval: float = 2.0  # AI auto-spawn
@export var spawn_offset: Vector2 = Vector2(550, 900)  # Right/left of hill
@export var ant_cost: float = 20.0  # Player deducts from anthill food

var timer: Timer
var anthill: Node  # Auto-find or set

func _ready():
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.timeout.connect(_auto_spawn)
	add_child(timer)
	timer.start()
	anthill = get_parent().get_node("PlayerAnthill") if team == Team.PLAYER else get_parent().get_node("EnemyAnthill")

func spawn_now():  # Player button calls this
	if team == Team.PLAYER and anthill.food < ant_cost: return
	if team == Team.PLAYER: anthill.food -= ant_cost
	_do_spawn()

func _auto_spawn():  # AI
	_do_spawn()

func _do_spawn():
	var ant = ant_scene.instantiate()
	ant.team = team
	ant.global_position = global_position + spawn_offset * (1.0 if team == Team.PLAYER else -1.0)
	get_parent().add_child(ant)
