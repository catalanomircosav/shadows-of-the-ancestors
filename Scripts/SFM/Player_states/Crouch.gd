extends State
class_name CrouchState

const CROUCH_SPEED_RATIO  := 0.3
const CROUCH_ANIM_SCALE   := 0.5
const SPRITE_SCALE_CROUCH := Vector2(1.0, 0.9)
const SPRITE_OFFSET_Y     := 5.0

var _player: Player
var _original_scale: Vector2
var _original_position: Vector2
var _step_timer: float = 0.0

func _setup() -> void:
	_player = state_machine.get_parent() as Player

func enter(_previous_state: StringName = &"", data: Dictionary = {}) -> void:
	_original_scale = _player.sprite.scale
	_original_position = _player.sprite.position
	_player.sprite.scale      = SPRITE_SCALE_CROUCH
	_player.sprite.position.y = _original_position.y + SPRITE_OFFSET_Y
	_play_crouch_animation("idle")
	_step_timer = 0.0

func exit(_next_state: StringName = &"") -> void:
	_player.sprite.scale = _original_scale
	_player.sprite.position = _original_position
	_player.anim_player.speed_scale = 1.0

func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("crouch"):
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		state_machine.transition_to(&"Walk" if input_dir != Vector2.ZERO else &"Idle")
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_player.velocity = _player.velocity.move_toward(
		input_dir * _player.max_speed * CROUCH_SPEED_RATIO,
		_player.acceleration
	)
	_player.move_and_slide()

	if input_dir != Vector2.ZERO:
		_player.update_facing_direction(input_dir)
		_play_crouch_animation("walk", CROUCH_ANIM_SCALE)

		_step_timer -= delta
		if _step_timer <= 0.0:
			NoiseManager.emit_step("CROUCH")
			_step_timer = NoiseManager.STEP_INTERVAL["CROUCH"]
	else:
		_play_crouch_animation("idle")
		_step_timer = 0.0  # resetta quando fermo in crouch

func _play_crouch_animation(type: String, speed_scale: float = 1.0) -> void:
	_player.play_animation(type + "_" + _player.last_facing, speed_scale)
