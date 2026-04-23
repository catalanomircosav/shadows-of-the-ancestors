## crouch_state.gd
extends State
class_name CrouchState

const CROUCH_SPEED_RATIO  := 0.3
const CROUCH_ANIM_SCALE   := 0.5
const SPRITE_SCALE_CROUCH := Vector2(1.0, 0.9)
const SPRITE_OFFSET_Y     := 5.0

var _player: Player


func _setup() -> void:
	_player = state_machine.get_parent() as Player


func enter(_previous_state: StringName = &"") -> void:
	_player.sprite.scale      = SPRITE_SCALE_CROUCH
	_player.sprite.position.y = SPRITE_OFFSET_Y
	_play_crouch_animation("idle")


func exit(_next_state: StringName = &"") -> void:
	_player.sprite.scale      = Vector2.ONE
	_player.sprite.position.y = 0.0
	_player.anim_player.speed_scale = 1.0


func physics_update(_delta: float) -> void:
	var input_dir
	if not Input.is_action_pressed("crouch"):
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		state_machine.transition_to(&"Walk" if input_dir != Vector2.ZERO else &"Idle")
		return

	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_player.velocity = _player.velocity.move_toward(
		input_dir * _player.max_speed * CROUCH_SPEED_RATIO,
		_player.acceleration
	)
	_player.move_and_slide()

	if input_dir != Vector2.ZERO:
		_player.update_facing_direction(input_dir)
		_play_crouch_animation("walk", CROUCH_ANIM_SCALE)
	else:
		_play_crouch_animation("idle")

func _play_crouch_animation(type: String, speed_scale: float = 1.0) -> void:
	_player.play_animation(type + "_" + _player.last_facing, speed_scale)
