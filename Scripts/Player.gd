extends CharacterBody2D
class_name Player

@export var acceleration: int = 80
@export var max_speed: int = 250
@export var friction: int = 100

var move_direction: Vector2 = Vector2.ZERO
var last_facing: String = "down" # default

# ----------- helpers ----------------------------------------
func update_facing_direction(direction: Vector2) -> void:
	if direction.x > 0: last_facing = "right"
	elif direction.x < 0: last_facing = "left"
	elif direction.y > 0: last_facing = "down"
	elif direction.y < 0: last_facing = "up"
