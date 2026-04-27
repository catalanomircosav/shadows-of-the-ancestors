extends State
class_name RunState
# ==============================================================================
# SCRIPT: Run.gd (RunState)
# DESCRIZIONE: Stato di corsa del giocatore. Gestisce il movimento ad alta
# velocità, l'emissione dei rumori dei passi (più frequenti e rumorosi) e le 
# transizioni verso camminata, inattività o attacchi.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _player: Player
var _step_timer: float = 0.0


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
	# Avvia l'animazione di corsa in base alla direzione in cui il giocatore guarda
	_player.play_animation("run_" + _player.last_facing, 1.0, true)
	
	# Resetta il timer del rumore dei passi
	_step_timer = 0.0

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# --- CONTROLLO INPUT E TRANSIZIONI (In ordine di priorità) ---

	# 1. Attacco Leggero
	if Input.is_action_just_pressed("light_attack"):
		state_machine.transition_to(&"LightAttack")
		return
		
	# 2. Attacco Pesante
	if Input.is_action_just_pressed("heavy_attack"):
		state_machine.transition_to(&"HeavyAttack")
		return
		
	# 3. Ritorno in Inattività se non c'è input di movimento
	if input_dir == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return
		
	# 4. Ritorno a Camminata se il tasto di corsa viene rilasciato
	if not Input.is_action_pressed("run"):
		state_machine.transition_to(&"Walk")
		return

	# --- AGGIORNAMENTO MOVIMENTO E GRAFICA ---
	
	# Aggiorna la direzione verso cui il giocatore è rivolto
	_player.update_facing_direction(input_dir)
	
	# Calcola la nuova velocità accelerando verso la direzione usando run_speed
	_player.velocity = _player.velocity.move_toward(
		input_dir * _player.run_speed, 
		_player.acceleration
	)
	
	# Aggiorna costantemente l'animazione di corsa
	_player.play_animation("run_" + _player.last_facing, 1.0)
	
	# Applica il movimento al CharacterBody2D
	_player.move_and_slide()

	# --- GESTIONE EMISSIONE RUMORE (Passi) ---
	
	_step_timer -= delta
	if _step_timer <= 0.0:
		NoiseManager.emit_step("RUN")
		_step_timer = NoiseManager.STEP_INTERVAL["RUN"]
