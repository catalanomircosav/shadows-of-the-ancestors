extends Node2D

@onready var light = $PointLight2D
@onready var sprite = $AnimatedSprite2D
@onready var e: = $E
var is_lit: bool = true
var player_in_range: bool = false

func _ready():
	sprite.play("default")

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		toggle_torch()
		
func toggle_torch():
	is_lit = !is_lit
	light.enabled = is_lit
	if is_lit:
		sprite.play("default")
	else:
		sprite.play("unlit")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		e.visible = true
	

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		e.visible = false
