extends State
class_name RunState

var _player: Player
var _step_timer: float = 0.0

func _setup() -> void:
	_player = state_machine.get_parent() as Player

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player.play_animation("run_" + _player.last_facing, 1.0, true)
	_step_timer = 0.0

func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if Input.is_action_just_pressed("light_attack"):
		state_machine.transition_to(&"LightAttack")
		return
	if Input.is_action_just_pressed("heavy_attack"):
		state_machine.transition_to(&"HeavyAttack")
		return
	if input_dir == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return
	if not Input.is_action_pressed("run"):
		state_machine.transition_to(&"Walk")
		return

	_player.update_facing_direction(input_dir)
	_player.velocity = _player.velocity.move_toward(input_dir * _player.run_speed, _player.acceleration)
	_player.play_animation("run_" + _player.last_facing, 1.0)
	_player.move_and_slide()

	_step_timer -= delta
	if _step_timer <= 0.0:
		NoiseManager.emit_step("RUN")
		_step_timer = NoiseManager.STEP_INTERVAL["RUN"]
