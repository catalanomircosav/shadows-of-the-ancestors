extends State
class_name IdleState

@onready var player: Player = owner

func enter(_previous_state: StringName = &"") -> void:
	player.get_node("AnimationPlayer").play("idle_" + player.last_facing)

func physics_update(_delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction)
	player.move_and_slide()
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO: state_machine.transition_to(&"Walk")
	
	if Input.is_action_just_pressed("attack"): state_machine.transition_to(&"Attack")
