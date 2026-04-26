extends State
class_name EnemyIdleState

var _enemy: CharacterBody2D
var _idle_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as CharacterBody2D

func enter(_previous_state: StringName = &"") -> void:
	_enemy.velocity = Vector2.ZERO
	
	_idle_timer = randf_range(1.0, 3.0)

	if _enemy.has_method("play_animation"):
		_enemy.play_animation("idle_" + _enemy.last_facing)

func physics_update(delta: float) -> void:
	_idle_timer -= delta
	
	if _idle_timer <= 0:
		state_machine.transition_to(&"Wander")
