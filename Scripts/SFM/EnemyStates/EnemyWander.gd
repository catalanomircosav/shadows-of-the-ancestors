extends State
class_name EnemyWanderState
# ==============================================================================
# SCRIPT: enemy_wander.gd
# ==============================================================================

const WANDER_SPEED: float = 30.0
const VISION_RANGE: float = 200.0
const CLOSE_VISION_RANGE: float = 80.0
const HEARING_MULTIPLIER: float = 2.0 

var _enemy: EnemyBase
var _player: Player
var _raycast: RayCast2D
var _direction: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

# Variabili per il tempo di reazione
var _is_reacting: bool = false
var _reaction_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase
	_raycast = _enemy.get_node("RayCast2D")

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	
	var dirs: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	_direction = dirs.pick_random()
	
	_wander_timer = randf_range(2.0, 4.0)
	
	_enemy.update_facing_direction(_direction)
	_enemy.play_animation("idle_" + _enemy.last_facing)
	
	_is_reacting = true
	_reaction_timer = randf_range(0.8, 1.5)

func physics_update(delta: float) -> void:
	
	# 1. VISIONE DINAMICA E CONO VISIVO
	if is_instance_valid(_player):
		var player_vis: float = VisibilityManager.get_visibility()
		var dynamic_vision_range: float = CLOSE_VISION_RANGE + ((VISION_RANGE - CLOSE_VISION_RANGE) * player_vis)
		
		# Deleghiamo il controllo visivo (Crouch, FOV, Muri) al nemico
		if _enemy.can_see_player(_player, dynamic_vision_range):
			_enemy.velocity = Vector2.ZERO
			# ---- NUOVO: ATTIVA VIA DI FUGA ----
			if _player.has_method("trigger_escape_route"):
				_player.trigger_escape_route()
			# -----------------------------------
			state_machine.transition_to(&"Chase")
			return
	
	# 2. CONTROLLO RUMORI
	var current_noise_radius: float = NoiseManager.get_noise_radius()
	if current_noise_radius > 0.0:
		var noise_pos: Vector2 = NoiseManager.get_noise_position()
		var distance: float = _enemy.global_position.distance_to(noise_pos)
		
		if distance <= (current_noise_radius * HEARING_MULTIPLIER):
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Investigate")
			return
			
	# 3. FASE DI REAZIONE
	if _is_reacting:
		_reaction_timer -= delta
		if _reaction_timer <= 0.0:
			_is_reacting = false
			_enemy.play_animation("run_" + _enemy.last_facing)
		return

	# 4. AGGIORNAMENTO VAGABONDAGGIO E MOVIMENTO
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	_raycast.target_position = _direction * 15.0
	_raycast.force_raycast_update()
	
	if _raycast.is_colliding() or _enemy.is_on_wall():
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	_enemy.velocity = _direction * WANDER_SPEED
	_enemy.move_and_slide()
