## walk_state.gd
## Stato di camminata: movimento a velocità normale.
extends State
class_name WalkState

var _player: Player


func _setup() -> void:
	_player = state_machine.get_parent() as Player


func enter(_previous_state: StringName = &"") -> void:
	_player.play_animation("walk_" + _player.last_facing)


func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	if Input.is_action_pressed("run"):
		state_machine.transition_to(&"Run")
		return

	if Input.is_action_pressed("crouch"):
		state_machine.transition_to(&"Crouch")
		return

	_player.update_facing_direction(input_dir)
	_player.velocity = _player.velocity.move_toward(input_dir * _player.max_speed, _player.acceleration)
	_player.play_animation("walk_" + _player.last_facing)
	_player.move_and_slide()
