## attack_base.gd
## Classe base per gli stati di attacco.
## Non va registrata come stato nella scena — usare LightAttackState e HeavyAttackState.
extends State
class_name AttackBase

const MOVE_SPEED_RATIO := 0.35

var _player: Player
var _current_anim_name: String = ""


func _setup() -> void:
	_player = state_machine.get_parent() as Player
	for anim_name in _player.anim_player.get_animation_list():
		if anim_name.begins_with("light_attack_") or anim_name.begins_with("heavy_attack_"):
			_player.anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_NONE


func enter(_previous_state: StringName = &"") -> void:
	_current_anim_name = ""
	_play_attack_animation()


func exit(_next_state: StringName = &"") -> void:
	_current_anim_name = ""


func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		_player.velocity = _player.velocity.move_toward(
			input_dir * _player.max_speed * MOVE_SPEED_RATIO,
			_player.acceleration
		)
	else:
		_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.friction)
	_player.move_and_slide()

	if _current_anim_name != "" and not _player.anim_player.is_playing():
		_on_animation_ended()


## Sovrascrivere nelle sottoclassi per restituire il prefisso corretto.
## Es: "light_attack" oppure "heavy_attack"
func _get_anim_prefix() -> String:
	return ""


func _play_attack_animation() -> void:
	_current_anim_name = _get_anim_prefix() + "_" + _player.last_facing
	_player.anim_player.speed_scale = 1.0
	_player.anim_player.play(_current_anim_name)


func _on_animation_ended() -> void:
	_current_anim_name = ""
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		state_machine.transition_to(&"Walk")
	else:
		state_machine.transition_to(&"Idle")
