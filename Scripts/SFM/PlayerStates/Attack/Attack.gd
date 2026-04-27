extends State
class_name AttackBase
# ==============================================================================
# SCRIPT: Attack.gd (AttackBase)
# DESCRIZIONE: Classe base per gli stati di attacco del giocatore. Gestisce 
# il rallentamento del movimento durante l'attacco, l'attivazione/disattivazione
# dell'hitbox e la transizione alla fine dell'animazione.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE
# ------------------------------------------------------------------------------
@export var move_speed_ratio: float = 0.35
@export var attack_damage: int = 10
@export var backstab_bonus: int = 2

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _player: Player
var _current_anim_name: String = ""


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	_player = state_machine.get_parent() as Player
	
	# Assicura via codice che le animazioni di attacco non vadano in loop
	for anim_name in _player.anim_player.get_animation_list():
		if anim_name.begins_with("light_attack_") or anim_name.begins_with("heavy_attack_"):
			_player.anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_NONE


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_current_anim_name = ""
	
	# Configura l'hitbox della spada per il colpo attuale
	_player.sword_hitbox.damage = attack_damage
	_player.sword_hitbox.disable()  # Parte sempre disabilitata (si abilita via track)
	
	_play_attack_animation()

## Chiamato dalla StateMachine quando si esce da questo stato.
func exit(_next_state: StringName = &"") -> void:
	_current_anim_name = ""
	
	# Sicurezza: si assicura che l'hitbox sia sempre spento all'uscita dello stato
	_player.sword_hitbox.disable()

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(_delta: float) -> void:
	# Rileva il movimento per permettere al giocatore di spostarsi leggermente mentre attacca
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		_player.velocity = _player.velocity.move_toward(
			input_dir * _player.max_speed * move_speed_ratio,
			_player.acceleration
		)
	else:
		_player.velocity = _player.velocity.move_toward(Vector2.ZERO, _player.friction)
		
	_player.move_and_slide()
	
	# Controlla costantemente se l'animazione in riproduzione è giunta al termine
	if _current_anim_name != "" and not _player.anim_player.is_playing():
		_on_animation_ended()


# ==============================================================================
# METODI DI SUPPORTO (HELPERS E VIRTUALI)
# ==============================================================================

## Metodo virtuale: destinato ad essere sovrascritto dalle classi figlie
## (es. restituendo "light_attack" o "heavy_attack").
func _get_anim_prefix() -> String:
	return ""

## Compone il nome dell'animazione e la avvia sul giocatore.
func _play_attack_animation() -> void:
	_current_anim_name = _get_anim_prefix() + "_" + _player.last_facing
	_player.play_animation(_current_anim_name, 1.0, true)

## Gestisce la logica di transizione una volta conclusa l'animazione di attacco.
func _on_animation_ended() -> void:
	_current_anim_name = ""
	
	# Disabilita l'hitbox per sicurezza quando l'animazione finisce
	_player.sword_hitbox.disable() 
	
	# Decide il prossimo stato in base agli input attuali del giocatore
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		state_machine.transition_to(&"Walk")
	else:
		state_machine.transition_to(&"Idle")


# ==============================================================================
# CALLBACK DELLE ANIMAZIONI (CALL METHOD TRACKS)
# ==============================================================================

## Chiamato dall'AnimationPlayer al frame esatto in cui l'arma colpisce.
func _on_hit_frame() -> void:
	_player.sword_hitbox.enable()   # Abilitare l'hitbox svuota la lista _hit_this_swing

## Chiamato dall'AnimationPlayer al frame esatto in cui il colpo termina la sua efficacia.
func _on_hit_end_frame() -> void:
	_player.sword_hitbox.disable()  # Disabilita quando la spada viene ritirata
