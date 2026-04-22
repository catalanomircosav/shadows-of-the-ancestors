extends CharacterBody2D
class_name Player

@export var acceleration: int = 80
@export var max_speed: int = 250
@export var friction: int = 20

var move_direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void: 
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()
		velocity += move_direction * acceleration
		velocity = velocity.limit_length(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
		
	move_and_slide()
