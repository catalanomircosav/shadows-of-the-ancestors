extends State
class_name EnemyInvestigateState
# ==============================================================================
# SCRIPT: enemy_investigate.gd
# DESCRIZIONE: Stato di investigazione. Il nemico si muove verso la posizione
# di un rumore rilevato. Se durante l'indagine scorge il giocatore, passa
# allo stato Chase. Se raggiunge il punto a vuoto o scade il tempo, torna in Idle.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const INVESTIGATE_SPEED: float = 60.0
const ARRIVAL_TOLERANCE: float = 15.0

# Parametri di visione per rilevare il giocatore
const VISION_RANGE: float = 160.0      # Distanza massima a cui vede il player illuminato
const CLOSE_VISION_RANGE: float = 60.0 # Distanza a cui vede il player anche al buio

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _player: Player
var _direction_anim: Vector2 = Vector2.ZERO
var _investigate_timer: float = 0.0


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	# Tenta di recuperare il riferimento al giocatore
	_player = get_tree().get_first_node_in_group("player") as Player
	
	# Imposta un timer di timeout per l'investigazione
	_investigate_timer = 5.0
	
	# Aggiorna immediatamente la direzione e l'animazione
	_update_movement_and_anim()

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	
	# 1. CONTROLLO VISIONE DEL GIOCATORE (Passaggio a CHASE)
	if is_instance_valid(_player):
		var dist_to_player: float = _enemy.global_position.distance_to(_player.global_position)
		var player_vis: float = VisibilityManager.get_visibility()
		
		# Se il giocatore è vicinissimo (anche nell'ombra) OPPURE 
		# è a portata di vista ed è sufficientemente illuminato (> 0.2)
		if dist_to_player <= CLOSE_VISION_RANGE or (dist_to_player <= VISION_RANGE and player_vis > 0.2):
			_enemy.velocity = Vector2.ZERO
			state_machine.transition_to(&"Chase")
			return
	
	# 2. LOGICA DI INVESTIGAZIONE DEL RUMORE (Movimento)
	_investigate_timer -= delta
	var distance_to_noise: float = _enemy.global_position.distance_to(_enemy.noise_target_position)
	
	# Controlla se il nemico ha raggiunto la destinazione del rumore o ha esaurito il tempo
	if distance_to_noise <= ARRIVAL_TOLERANCE or _investigate_timer <= 0.0:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	# Muove il nemico in linea retta verso la sorgente del rumore
	var real_direction: Vector2 = _enemy.global_position.direction_to(_enemy.noise_target_position)
	_enemy.velocity = real_direction * INVESTIGATE_SPEED
	_enemy.move_and_slide()
	
	# Aggiorna l'animazione in base alla direzione del movimento
	_update_movement_and_anim()
	
	# Penalità di tempo: se il nemico urta un muro, rinuncia più in fretta
	if _enemy.is_on_wall():
		_investigate_timer -= delta * 3.0


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Determina l'asse di movimento principale per impostare l'animazione corretta.
func _update_movement_and_anim() -> void:
	var real_dir: Vector2 = _enemy.global_position.direction_to(_enemy.noise_target_position)
	
	# Sceglie l'asse dominante (X o Y) per decidere la direzione dello sprite
	if abs(real_dir.x) > abs(real_dir.y):
		_direction_anim = Vector2.RIGHT if real_dir.x > 0 else Vector2.LEFT
	else:
		_direction_anim = Vector2.DOWN if real_dir.y > 0 else Vector2.UP
		
	# Aggiorna lo stato della direzione nel nemico e riproduce l'animazione
	_enemy.update_facing_direction(_direction_anim)
	_enemy.play_animation("run_" + _enemy.last_facing)
