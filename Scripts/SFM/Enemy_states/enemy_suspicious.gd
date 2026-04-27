extends State
class_name EnemyInvestigateState

const INVESTIGATE_SPEED: float = 60.0
const ARRIVAL_TOLERANCE: float = 15.0

var _enemy: EnemyBase
var _direction_anim: Vector2 = Vector2.ZERO
var _investigate_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_investigate_timer = 5.0
	_update_movement_and_anim()

func physics_update(delta: float) -> void:
	_investigate_timer -= delta

	var distance = _enemy.global_position.distance_to(_enemy.noise_target_position)

	if distance <= ARRIVAL_TOLERANCE or _investigate_timer <= 0.0:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return

	var real_direction = _enemy.global_position.direction_to(_enemy.noise_target_position)
	_enemy.velocity = real_direction * INVESTIGATE_SPEED
	_enemy.move_and_slide()

	_update_movement_and_anim()

	if _enemy.is_on_wall():
		_investigate_timer -= delta * 3.0

func _update_movement_and_anim() -> void:
	var real_dir = _enemy.global_position.direction_to(_enemy.noise_target_position)

	if abs(real_dir.x) > abs(real_dir.y):
		_direction_anim = Vector2.RIGHT if real_dir.x > 0 else Vector2.LEFT
	else:
		_direction_anim = Vector2.DOWN if real_dir.y > 0 else Vector2.UP

	_enemy.update_facing_direction(_direction_anim)
	_enemy.play_animation("run_" + _enemy.last_facing)
