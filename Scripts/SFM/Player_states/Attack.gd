extends State
class_name AttackBase

@export var move_speed_ratio: float = 0.35
@export var attack_damage: int = 10

var _player: Player
var _current_anim_name: String = ""

func _setup() -> void:
	_player = state_machine.get_parent() as Player
	for anim_name in _player.anim_player.get_animation_list():
		if anim_name.begins_with("light_attack_") or anim_name.begins_with("heavy_attack_"):
			_player.anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_NONE

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_current_anim_name = ""
	_player.sword_hitbox.damage = attack_damage
	_player.sword_hitbox.disable()  # parte sempre disabilitata
	_play_attack_animation()

func exit(_next_state: StringName = &"") -> void:
	_current_anim_name = ""
	_player.sword_hitbox.disable()  # sicurezza: disabilita sempre all'uscita

func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		_player.velocity = _player.velocity.move_toward(
			input_dir * _player.max_speed * move_speed_ratio,
			_player.acceleration
		)
	else:
		_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.friction)
	_player.move_and_slide()
	if _current_anim_name != "" and not _player.anim_player.is_playing():
		_on_animation_ended()

func _get_anim_prefix() -> String:
	return ""

func _play_attack_animation() -> void:
	_current_anim_name = _get_anim_prefix() + "_" + _player.last_facing
	_player.play_animation(_current_anim_name, 1.0, true)

func _on_animation_ended() -> void:
	_current_anim_name = ""
	_player.sword_hitbox.disable()  # disabilita quando l'animazione finisce
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		state_machine.transition_to(&"Walk")
	else:
		state_machine.transition_to(&"Idle")

# ── Chiamati dalla Call Method Track ──────────────────────────────────────

func _on_hit_frame() -> void:
	_player.sword_hitbox.enable()   # abilita al frame di impatto → svuota _hit_this_swing

func _on_hit_end_frame() -> void:
	_player.sword_hitbox.disable()  # disabilita quando la spada si ritira
