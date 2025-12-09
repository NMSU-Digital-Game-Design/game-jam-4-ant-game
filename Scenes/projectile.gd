# Projectile.gd
extends Area2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 600
var damage : float = 15
var team

func _process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage") and (body.team != team):
		body.take_damage(damage)
		queue_free()
