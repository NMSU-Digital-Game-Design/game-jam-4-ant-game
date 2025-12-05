extends CharacterBody2D

@export var speed = 100

func _ready():
	add_to_group("enemy_ant")  # for collision detection

func _physics_process(delta):
	position.x -= speed * delta
