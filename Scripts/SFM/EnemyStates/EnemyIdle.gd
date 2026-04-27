extends State
class_name EnemyIdleState
# ==============================================================================
# SCRIPT: enemy_idle.gd
# DESCRIZIONE: Stato di inattività del nemico. Il nemico si ferma, riproduce
# l'animazione di idle e ascolta eventuali rumori nei dintorni prima di passare
# allo stato di vagabondaggio (Wander).
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _idle_timer: float = 0.0


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato (probabilmente dalla StateMachine) per inizializzare i riferimenti.
func _setup() -> void:
	# Ottiene il riferimento all'entità nemico che possiede la macchina a stati
	_enemy = state_machine.get_parent() as EnemyBase


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	# Ferma il movimento del nemico
	_enemy.velocity = Vector2.ZERO
	
	# Imposta un timer casuale per la durata dell'inattività
	_idle_timer = randf_range(3.0, 6.0)
	
	# Avvia l'animazione di idle nella direzione in cui il nemico stava guardando
	_enemy.play_animation("idle_" + _enemy.last_facing)

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	# 1. Controlla se ci sono rumori attivi nel livello
	var current_noise_radius: float = NoiseManager.get_noise_radius()
	
	if current_noise_radius > 0.0:
		var noise_pos: Vector2 = NoiseManager.get_noise_position()
		var distance: float = _enemy.global_position.distance_to(noise_pos)
		
		# Se il rumore è abbastanza vicino, il nemico si insospettisce
		if distance <= current_noise_radius:
			_enemy.noise_target_position = noise_pos
			state_machine.transition_to(&"Investigate")
			return
			
	# 2. Gestisce il timer di inattività se non è stato distratto da rumori
	_idle_timer -= delta
	if _idle_timer <= 0.0:
		# Scaduto il tempo, il nemico riprende a vagabondare
		state_machine.transition_to(&"Wander")
