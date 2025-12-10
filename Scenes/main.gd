extends Node2D
enum Team { PLAYER, ENEMY }

@onready var player = $PlayerAnthill/PlayerAnthill
@onready var enemy = $EnemyAnthill/EnemyAnthill
@onready var game_over = $GameOver

func _ready():
	player.anthill_died.connect(_on_anthill_death)
	enemy.anthill_died.connect(_on_anthill_death)
	game_over.play_again.connect(restart_game)
	

func _on_anthill_death(team):
	get_tree().paused = true
	
	if team == Team.ENEMY:
		print("Player Won")
		game_over.show_win()
	else:
		print("Player Lost")
		game_over.show_loss()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
