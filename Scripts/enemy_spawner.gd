extends Node2D

@export var spawn_interval = 2.0
var EnemyAntScene = preload("res://Scenes/enemy_ant.tscn")

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(Callable(self, "_spawn_enemy_ant"))
	timer.start()
	print("EnemySpawner ready")

func _spawn_enemy_ant():
	print("Spawning enemy ant")
	var ant = EnemyAntScene.instantiate()
	ant.position = Vector2(600, 700)  # adjust lane Y if needed
	get_parent().add_child(ant)
