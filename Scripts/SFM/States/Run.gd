## run_state.gd
## Stato di corsa: movimento a velocità aumentata.
extends State
class_name RunState

var _player: Player


func _setup() -> void:
	_player = state_machine.get_parent() as Player


func enter(_previous_state: StringName = &"") -> void:
	_player.play_animation("run_" + _player.last_facing, 1.0, true)


func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	if not Input.is_action_pressed("run"):
		state_machine.transition_to(&"Walk")
		return

	_player.update_facing_direction(input_dir)
	_player.velocity = _player.velocity.move_toward(input_dir * _player.run_speed, _player.acceleration)
	_player.play_animation("run_" + _player.last_facing, 1.0, true)
	_player.move_and_slide()
