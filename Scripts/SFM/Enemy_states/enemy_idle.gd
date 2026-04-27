extends State
class_name EnemyIdleState

var _enemy: EnemyBase
var _idle_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_enemy.velocity = Vector2.ZERO
	_idle_timer = randf_range(3.0, 6.0)
	_enemy.play_animation("idle_" + _enemy.last_facing)

func physics_update(delta: float) -> void:
	var current_noise_radius = NoiseManager.get_noise_radius()
	if current_noise_radius > 0.0:
		var noise_pos = NoiseManager.get_noise_position()
		var distance = _enemy.global_position.distance_to(noise_pos)
		if distance <= current_noise_radius:
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Suspicious")
			return

	_idle_timer -= delta
	if _idle_timer <= 0.0:
		state_machine.transition_to(&"Wander")
