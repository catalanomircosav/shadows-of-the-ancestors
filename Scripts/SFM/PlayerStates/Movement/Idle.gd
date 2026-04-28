extends State
class_name IdleState
# ==============================================================================
# SCRIPT: Idle.gd (IdleState)
# DESCRIZIONE: Stato di inattività del giocatore. Decelera fino a fermarsi,
# riproduce l'animazione di idle e ascolta gli input per transizionare verso
# attacchi, movimento, accovacciamento o lancio magie.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _player: Player


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	_player = state_machine.get_parent() as Player


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	# Riproduce l'animazione di idle nella direzione in cui il giocatore guarda
	_player.play_animation("idle_" + _player.last_facing, 1.0, true)

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(_delta: float) -> void:
	# Applica l'attrito per fermare dolcemente il personaggio se aveva inerzia
	_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.friction)
	_player.move_and_slide()

	# --- CONTROLLO INPUT E TRANSIZIONI (In ordine di priorità) ---

	# 1. Attacco Leggero
	if Input.is_action_just_pressed("light_attack"):
		state_machine.transition_to(&"LightAttack")
		return
		
	# 2. Attacco Pesante
	if Input.is_action_just_pressed("heavy_attack"):
		state_machine.transition_to(&"HeavyAttack")
		return
	
	# 3. Movimento (Camminata)
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		state_machine.transition_to(&"Walk")
		return

	# 4. Accovacciamento (Crouch)
	if Input.is_action_pressed("crouch"):
		state_machine.transition_to(&"Crouch")
		return
