extends State
class_name WalkState

@onready var player: Player = owner

func enter(_previous_state: StringName = &"") -> void:
	player.get_node("AnimationPlayer").play("walk_" + player.last_facing)

func physics_update(_delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return
	
	player.update_facing_direction(input_dir)
	player.velocity = player.velocity.move_toward(input_dir * player.max_speed, player.acceleration)
	
	player.get_node("AnimationPlayer").play("walk_" + player.last_facing)
	
	player.move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to(&"Attack")
