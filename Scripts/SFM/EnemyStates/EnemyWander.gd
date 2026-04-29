extends State
class_name EnemyWanderState
# ==============================================================================
# SCRIPT: enemy_wander.gd
# DESCRIZIONE: Stato di vagabondaggio. Il nemico sceglie una direzione casuale,
# cammina per un breve periodo. Se vede il player, sente un rumore, incontra 
# un ostacolo o finisce il tempo, interrompe il vagabondaggio.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const WANDER_SPEED: float = 40.0

# Parametri di visione per rilevare il giocatore mentre pattuglia
const VISION_RANGE: float = 160.0
const CLOSE_VISION_RANGE: float = 60.0

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _player: Player
var _raycast: RayCast2D
var _direction: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase
	# Presuppone che il nemico abbia esattamente un nodo chiamato "RayCast2D"
	_raycast = _enemy.get_node("RayCast2D")


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	# Tenta di recuperare il riferimento al giocatore
	_player = get_tree().get_first_node_in_group("player") as Player
	
	# Sceglie una direzione casuale SOLO all'inizio del vagabondaggio
	var dirs: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	_direction = dirs.pick_random()
	
	# Imposta la durata della passeggiata
	_wander_timer = randf_range(1.0, 3.0)
	
	# Aggiorna lo sguardo e l'animazione
	_enemy.update_facing_direction(_direction)
	_enemy.play_animation("run_" + _enemy.last_facing)


## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	
	# 1. CONTROLLO VISIONE DEL GIOCATORE
	if is_instance_valid(_player):
		var dist_to_player: float = _enemy.global_position.distance_to(_player.global_position)
		var player_vis: float = VisibilityManager.get_visibility()
		
		if _enemy.has_line_of_sight(_player):
			if dist_to_player <= CLOSE_VISION_RANGE or (dist_to_player <= VISION_RANGE and player_vis > 0.2):
				_enemy.velocity = Vector2.ZERO
				state_machine.transition_to(&"Chase")
				return
	
	# 2. CONTROLLO RUMORI
	var current_noise_radius: float = NoiseManager.get_noise_radius()
	if current_noise_radius > 0.0:
		var noise_pos: Vector2 = NoiseManager.get_noise_position()
		var distance: float = _enemy.global_position.distance_to(noise_pos)
		
		# Se il rumore è abbastanza vicino, il nemico interrompe il vagabondaggio
		if distance <= current_noise_radius:
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Investigate")
			return
			
	# 3. AGGIORNAMENTO TIMER VAGABONDAGGIO
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	# 4. CONTROLLO OSTACOLI (Fix per evitare che giri su se stesso all'infinito)
	_raycast.target_position = _direction * 15.0
	_raycast.force_raycast_update()
	
	# Se sbatte contro un muro, si arrende e si ferma subito per guardarsi intorno
	if _raycast.is_colliding() or _enemy.is_on_wall():
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	# 5. MOVIMENTO
	_enemy.velocity = _direction * WANDER_SPEED
	_enemy.move_and_slide()
