## idle_state.gd
extends State
class_name IdleState

var _player: Player


func _setup() -> void:
	_player = state_machine.get_parent() as Player


func enter(_previous_state: StringName = &"", data: Dictionary = {}) -> void:
	_player.play_animation("idle_" + _player.last_facing, 1.0, true)


func physics_update(_delta: float) -> void:
	_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.friction)
	_player.move_and_slide()

	if Input.is_action_just_pressed("light_attack"):
		state_machine.transition_to(&"LightAttack")
		return
		
	if Input.is_action_just_pressed("heavy_attack"):
		state_machine.transition_to(&"HeavyAttack")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		state_machine.transition_to(&"Walk")
		return

	if Input.is_action_pressed("crouch"):
		state_machine.transition_to(&"Crouch")
		return
