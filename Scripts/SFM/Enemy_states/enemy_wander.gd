extends State
class_name EnemyWanderState

const WANDER_SPEED: float = 40.0
const WALL_CHECK_DIST: float = 20.0

var _enemy: CharacterBody2D
var _raycast: RayCast2D

var _direction: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as CharacterBody2D
	_raycast = _enemy.get_node("RayCast2D")

func enter(_previous_state: StringName = &"") -> void:
	_pick_new_direction()

func physics_update(delta: float) -> void:
	_wander_timer -= delta
	
	if _wander_timer <= 0:
		state_machine.transition_to(&"Idle")
		return

	_raycast.target_position = _direction * 15.0 
	_raycast.force_raycast_update()
	
	_enemy.velocity = _direction * WANDER_SPEED
	_enemy.move_and_slide()

	if _raycast.is_colliding() or _enemy.is_on_wall():
		_enemy.velocity = Vector2.ZERO
		_pick_new_direction()

func _pick_new_direction() -> void:
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	_direction = dirs.pick_random()
	
	_wander_timer = randf_range(2.0, 4.0)
	
	_update_anim()

func _update_anim() -> void:
	var facing = "down"
	if _direction == Vector2.UP: facing = "up"
	elif _direction == Vector2.LEFT: facing = "left"
	elif _direction == Vector2.RIGHT: facing = "right"
	
	_enemy.last_facing = facing
	
	if _enemy.has_method("play_animation"):
		_enemy.play_animation("run_" + facing)
