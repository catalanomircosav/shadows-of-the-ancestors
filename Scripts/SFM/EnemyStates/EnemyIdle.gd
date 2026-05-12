extends State
class_name EnemyIdleState
# ==============================================================================
# SCRIPT: enemy_idle.gd
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const VISION_RANGE: float = 280.0      
const CLOSE_VISION_RANGE: float = 110.0 
const HEARING_MULTIPLIER: float = 2.0 

var _enemy: EnemyBase
var _player: Player
var _idle_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	
	_enemy.velocity = Vector2.ZERO
	
	_idle_timer = randf_range(3.0, 7.0)
	_enemy.play_animation("idle_" + _enemy.last_facing)

func physics_update(delta: float) -> void:
	
	# FIX: Se al primissimo frame il player non era ancora pronto, riproviamo a cercarlo!
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Player
	
	# 1. VISIONE DINAMICA E CONO VISIVO
	if is_instance_valid(_player):
		var player_vis: float = VisibilityManager.get_visibility()
		var dynamic_vision_range: float = CLOSE_VISION_RANGE + ((VISION_RANGE - CLOSE_VISION_RANGE) * player_vis)
		
		# Deleghiamo il controllo visivo al nemico
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
			
	# 3. AGGIORNAMENTO TIMER
	_idle_timer -= delta
	if _idle_timer <= 0.0:
		state_machine.transition_to(&"Wander")
