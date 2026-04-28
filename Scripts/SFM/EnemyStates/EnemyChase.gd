extends State
class_name EnemyChaseState
# ==============================================================================
# SCRIPT: enemy_chase.gd
# DESCRIZIONE: Stato di inseguimento. Il nemico localizza il giocatore tramite
# il gruppo "player" e lo insegue costantemente. Se il giocatore esce dal raggio
# di aggro o si nasconde nell'ombra, il nemico passa a Investigate. Se si
# avvicina abbastanza, passa allo stato Attack.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const CHASE_SPEED: float = 85.0
const ATTACK_RANGE: float = 30.0
const AGGRO_DROP_DISTANCE: float = 250.0

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _player: Player


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
	# Recupera dinamicamente il giocatore dalla scena usando i gruppi
	_player = get_tree().get_first_node_in_group("player") as Player
	
	# Fallback di sicurezza: se il player non esiste (es. è morto), torna in Idle
	if not is_instance_valid(_player):
		state_machine.transition_to(&"Idle")

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(_delta: float) -> void:
	# Ulteriore controllo di sicurezza nel caso il player venga distrutto a runtime
	if not is_instance_valid(_player):
		state_machine.transition_to(&"Idle")
		return
		
	var distance: float = _enemy.global_position.distance_to(_player.global_position)
	
	# 1. CONDIZIONE DI ATTACCO
	if distance <= ATTACK_RANGE:
		_enemy.velocity = Vector2.ZERO
		# Assicurati di creare uno stato "Attack" nella tua FSM!
		state_machine.transition_to(&"Attack") 
		return
		
	# 2. CONDIZIONE DI PERDITA DEL BERSAGLIO (Aggro Drop)
	var player_visibility: float = VisibilityManager.get_visibility()
	
	# Il nemico perde le tracce se il giocatore è troppo lontano, OPPURE 
	# se il giocatore è nell'ombra (visibilità < 0.2) ed è fuori dal raggio di visione ravvicinata
	if distance > AGGRO_DROP_DISTANCE or (player_visibility <= 0.2 and distance > 80.0):
		# Imposta l'ultima posizione nota del player come target per l'investigazione
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
	
	# Sceglie l'asse dominante (X o Y) per decidere la direzione dello sprite
	if abs(dir.x) > abs(dir.y):
		direction_anim = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		direction_anim = Vector2.DOWN if dir.y > 0 else Vector2.UP
		
	# Aggiorna lo stato della direzione nel nemico e riproduce l'animazione
	_enemy.update_facing_direction(direction_anim)
	
	# Presuppongo che durante l'inseguimento si usi la stessa animazione "run"
	_enemy.play_animation("run_" + _enemy.last_facing)
