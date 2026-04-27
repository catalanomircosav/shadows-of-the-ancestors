extends State
class_name EnemyWanderState
# ==============================================================================
# SCRIPT: enemy_wander.gd
# DESCRIZIONE: Stato di vagabondaggio. Il nemico sceglie una direzione casuale,
# cammina per un breve periodo evitando i muri tramite un RayCast2D e ascolta
# eventuali rumori. Al termine del tempo, torna in Idle.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const WANDER_SPEED: float = 40.0
const WALL_CHECK_DIST: float = 20.0 # Nota: attualmente ignorata nella logica

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
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
	# Sceglie subito una nuova direzione in cui iniziare a camminare
	_pick_new_direction()

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	# 1. Controlla se ci sono rumori rilevanti nei dintorni
	var current_noise_radius: float = NoiseManager.get_noise_radius()
	if current_noise_radius > 0.0:
		var noise_pos: Vector2 = NoiseManager.get_noise_position()
		var distance: float = _enemy.global_position.distance_to(noise_pos)
		
		# Se il rumore è abbastanza vicino, il nemico interrompe il vagabondaggio
		if distance <= current_noise_radius:
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Investigate")
			return
			
	# 2. Aggiorna il timer di vagabondaggio
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		state_machine.transition_to(&"Idle")
		return
		
	# 3. Aggiorna il raycast per controllare la presenza di ostacoli frontali
	_raycast.target_position = _direction * 15.0
	_raycast.force_raycast_update()
	
	# Se rileva un ostacolo col raycast o con la fisica di collisione (muro), 
	# si ferma e sceglie immediatamente una nuova direzione
	if _raycast.is_colliding() or _enemy.is_on_wall():
		_enemy.velocity = Vector2.ZERO
		_pick_new_direction()
		return
		
	# 4. Applica il movimento nella direzione scelta
	_enemy.velocity = _direction * WANDER_SPEED
	_enemy.move_and_slide()


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Sceglie casualmente una delle 4 direzioni cardinali per il movimento.
func _pick_new_direction() -> void:
	var dirs: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	_direction = dirs.pick_random()
	_wander_timer = randf_range(1.0, 3.0)
	_update_anim()

## Aggiorna la direzione dello sguardo dell'entità e l'animazione riprodotta.
func _update_anim() -> void:
	_enemy.update_facing_direction(_direction)
	_enemy.play_animation("run_" + _enemy.last_facing)
