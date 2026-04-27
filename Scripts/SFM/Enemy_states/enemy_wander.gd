extends State
class_name EnemyWanderState

const WANDER_SPEED: float = 40.0
const WALL_CHECK_DIST: float = 20.0

var _enemy: EnemyBase
var _raycast: RayCast2D
var _direction: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase
	_raycast = _enemy.get_node("RayCast2D")

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_pick_new_direction()

func physics_update(delta: float) -> void:
	var current_noise_radius = NoiseManager.get_noise_radius()
	if current_noise_radius > 0.0:
		var noise_pos = NoiseManager.get_noise_position()
		var distance = _enemy.global_position.distance_to(noise_pos)
		if distance <= current_noise_radius:
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Suspicious")
			return

	_wander_timer -= delta
	if _wander_timer <= 0.0:
		state_machine.transition_to(&"Idle")
		return

	_raycast.target_position = _direction * 15.0
	_raycast.force_raycast_update()

	if _raycast.is_colliding() or _enemy.is_on_wall():
		_enemy.velocity = Vector2.ZERO
		_pick_new_direction()
		return

	_enemy.velocity = _direction * WANDER_SPEED
	_enemy.move_and_slide()

func _pick_new_direction() -> void:
	var dirs := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	_direction = dirs.pick_random()
	_wander_timer = randf_range(1.0, 3.0)
	_update_anim()

func _update_anim() -> void:
	_enemy.update_facing_direction(_direction)
	_enemy.play_animation("run_" + _enemy.last_facing)
