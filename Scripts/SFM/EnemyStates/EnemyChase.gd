extends State
class_name EnemyChaseState
# ==============================================================================
# SCRIPT: enemy_chase.gd
# DESCRIZIONE: Stato di inseguimento. Il nemico insegue costantemente il player.
# Se la linea di tiro è bloccata (muri), se il giocatore si nasconde al buio 
# o si allontana troppo, il nemico perde le tracce e passa a Investigate.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const CHASE_SPEED: float = 50.0
const ATTACK_RANGE: float = 15.0 
const CLOSE_VISION_RANGE: float = 80.0
const AGGRO_DROP_DISTANCE: float = 250.0

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _player: Player


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	
	if not is_instance_valid(_player):
		state_machine.transition_to(&"Idle")
	
	get_tree().call_group("music_manager", "allerta_nemico")
	
func exit(_next_state: StringName = &"") -> void:
	# --- MUSICA: Avvisa il MusicManager che questo nemico ha smesso di inseguirti ---
	get_tree().call_group("music_manager", "calma_nemico")

func physics_update(_delta: float) -> void:
	if not is_instance_valid(_player):
		state_machine.transition_to(&"Idle")
		return
		
	var distance: float = _enemy.global_position.distance_to(_player.global_position)
	var diff: Vector2 = _player.global_position - _enemy.global_position
	
	# 1. CONDIZIONE DI ATTACCO (Distanza + Allineamento)
	var is_aligned: bool = abs(diff.x) < 12.0 or abs(diff.y) < 12.0
	
	if distance <= ATTACK_RANGE and is_aligned:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Attack") 
		return
		
	# 2. CONDIZIONE DI PERDITA DEL BERSAGLIO (Line of Sight + Buio + Distanza)
	var player_visibility: float = VisibilityManager.get_visibility()
	var can_see_player: bool = _enemy.has_line_of_sight(_player)
	
	# Il nemico perde l'aggro se:
	# A) C'è un muro in mezzo (can_see_player è false)
	# B) Il player è nell'ombra (< 0.2) ed è fuori dal raggio ravvicinato
	# C) Il player è scappato troppo lontano
	if not can_see_player or (player_visibility <= 0.2 and distance > CLOSE_VISION_RANGE) or distance > AGGRO_DROP_DISTANCE:
		# Memorizza l'ultima posizione in cui ti ha visto e va a controllare lì!
		_enemy.noise_target_position = _player.global_position
		state_machine.transition_to(&"Investigate")
		return
		
	# 3. INSEGUIMENTO (Movimento)
	var real_direction: Vector2 = _enemy.global_position.direction_to(_player.global_position)
	_enemy.velocity = real_direction * CHASE_SPEED
	_enemy.move_and_slide()
	
	# 4. AGGIORNAMENTO ANIMAZIONI E SGUARDO
	_update_movement_and_anim(real_direction)


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Determina l'asse di movimento principale per impostare l'animazione corretta.
func _update_movement_and_anim(dir: Vector2) -> void:
	var direction_anim: Vector2 = Vector2.ZERO
	
	if abs(dir.x) > abs(dir.y):
		direction_anim = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		direction_anim = Vector2.DOWN if dir.y > 0 else Vector2.UP
		
	_enemy.update_facing_direction(direction_anim)
	_enemy.play_animation("run_" + _enemy.last_facing)
