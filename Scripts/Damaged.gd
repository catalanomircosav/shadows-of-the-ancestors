extends State
class_name DamagedState

@export var kb_decay: float = 800.0

var _owner: CharacterBody2D
var _kb_direction: Vector2 = Vector2.ZERO
var _kb_force: float = 0.0
var _active: bool = false

func _setup() -> void:
	_owner = state_machine.get_parent() as CharacterBody2D

func enter(_previous_state: StringName = &"", data: Dictionary = {}) -> void:
	_active = true
	_kb_direction = data.get("direction", Vector2.ZERO)
	_kb_force     = data.get("force",     0.0)

	_owner.health.start_invincibility()

	var anim_name := "damaged_" + _direction_to_suffix(_kb_direction)
	_owner.play_animation(anim_name, 1.0, true)

	await _owner.anim_player.animation_finished

	if not _active:
		return

	_owner.health.force_end_invincibility()
	state_machine.transition_to(&"Idle")
	
func physics_update(delta: float) -> void:
	if _kb_force > 0.0:
		_owner.velocity = _kb_direction * _kb_force
		_kb_force = move_toward(_kb_force, 0.0, kb_decay * delta)
	else:
		_owner.velocity = Vector2.ZERO
	_owner.move_and_slide()

func exit(_next_state: StringName = &"") -> void:
	_active = false
	_kb_force = 0.0
	_kb_direction = Vector2.ZERO

func _direction_to_suffix(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return "down"
	if abs(dir.x) >= abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	else:
		return "down" if dir.y > 0.0 else "up"
