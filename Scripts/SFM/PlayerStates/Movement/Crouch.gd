extends State
class_name CrouchState
# ==============================================================================
# SCRIPT: Crouch.gd (CrouchState)
# DESCRIZIONE: Stato di accovacciamento del giocatore. Riduce la velocità,
# schiaccia visivamente lo sprite, modifica l'emissione dei rumori dei passi 
# e gestisce le transizioni verso camminata o inattività.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const CROUCH_SPEED_RATIO: float   = 0.3
const CROUCH_ANIM_SCALE: float    = 0.5
const SPRITE_SCALE_CROUCH: Vector2= Vector2(1.0, 0.9)
const SPRITE_OFFSET_Y: float      = 5.0

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _player: Player
var _original_scale: Vector2
var _original_position: Vector2
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
	# Salva le trasformazioni originali dello sprite per poterle ripristinare
	_original_scale = _player.sprite.scale
	_original_position = _player.sprite.position
	
	# Applica l'effetto visivo di "schiacciamento" (squish)
	_player.sprite.scale = SPRITE_SCALE_CROUCH
	_player.sprite.position.y = _original_position.y + SPRITE_OFFSET_Y
	
	_play_crouch_animation("idle")
	_step_timer = 0.0

## Chiamato dalla StateMachine quando si esce da questo stato.
func exit(_next_state: StringName = &"") -> void:
	# Ripristina le trasformazioni originali dello sprite e la velocità delle animazioni
	_player.sprite.scale = _original_scale
	_player.sprite.position = _original_position
	_player.anim_player.speed_scale = 1.0

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	var input_dir: Vector2
	
	# 1. Controlla se il giocatore ha rilasciato il tasto di accovacciamento
	if not Input.is_action_pressed("crouch"):
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# Transita in Walk se si sta muovendo, altrimenti in Idle
		state_machine.transition_to(&"Walk" if input_dir != Vector2.ZERO else &"Idle")
		return

	# 2. Ricalcola l'input per gestire il movimento accovacciato
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# ---- NUOVO: LOGICA "PASSO FELPATO" ----
	var current_speed_ratio = CROUCH_SPEED_RATIO
	if _player.skills and _player.skills.has_skill("passo_felpato"):
		print("LOGICA ATTIVA: Aumento velocità!")
		_player.velocity = input_dir * (_player.max_speed * 0.8) 
	else:
		_player.velocity = _player.velocity.move_toward(
			input_dir * _player.max_speed * current_speed_ratio,
			_player.acceleration
		)
	_player.move_and_slide()

	# 3. Aggiorna animazioni e direzione in base al movimento
	if input_dir != Vector2.ZERO:
		_player.update_facing_direction(input_dir)
		_play_crouch_animation("walk", CROUCH_ANIM_SCALE)

		# Gestione del timer per l'emissione del rumore dei passi (Crouch)
		_step_timer -= delta
		if _step_timer <= 0.0:
			NoiseManager.emit_step("CROUCH")
			_step_timer = NoiseManager.STEP_INTERVAL["CROUCH"]
	else:
		_play_crouch_animation("idle")
		_step_timer = 0.0  # Resetta il timer dei passi quando fermo


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Riproduce l'animazione desiderata ("idle" o "walk") accodando la direzione.
func _play_crouch_animation(type: String, speed_scale: float = 1.0) -> void:
	_player.play_animation(type + "_" + _player.last_facing, speed_scale)
