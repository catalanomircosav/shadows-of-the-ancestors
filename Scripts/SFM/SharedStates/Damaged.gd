extends State
class_name DamagedState
# ==============================================================================
# SCRIPT: Damaged.gd (DamagedState)
# DESCRIZIONE: Stato di danno. Applica un knockback (rinculo) all'entità,
# gestisce l'animazione di sofferenza, attiva l'invincibilità temporanea
# e restituisce il controllo (Idle) al termine dell'animazione.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE
# ------------------------------------------------------------------------------
@export var kb_decay: float = 800.0

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _owner: CharacterBody2D
var _kb_direction: Vector2 = Vector2.ZERO
var _kb_force: float = 0.0
var _active: bool = false


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	# Esegue il cast al tipo base di movimento (presupponendo che abbia 
	# anche le proprietà custom health, anim_player e il metodo play_animation)
	_owner = state_machine.get_parent() as CharacterBody2D


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", data: Dictionary = {}) -> void:
	_active = true
	
	# Estrae i dati del knockback passati dal segnale di danno
	_kb_direction = data.get("direction", Vector2.ZERO)
	_kb_force     = data.get("force",     0.0)

	# Avvia l'invincibilità per evitare danni multipli consecutivi
	_owner.health.start_invincibility()

	# Compone il nome dell'animazione in base alla direzione del rinculo e la riproduce
	var anim_name: String = "damaged_" + _direction_to_suffix(_kb_direction)
	_owner.play_animation(anim_name, 1.0, true)

	# Attende la fine dell'animazione prima di restituire il controllo
	await _owner.anim_player.animation_finished

	# Controlla se lo stato è stato interrotto (es. l'entità è morta nel frattempo)
	if not _active:
		return

	# Se l'animazione finisce regolarmente, termina l'invincibilità e torna in Idle
	_owner.health.force_end_invincibility()
	state_machine.transition_to(&"Idle")

## Chiamato dalla StateMachine ad ogni frame fisico (in _physics_process).
func physics_update(delta: float) -> void:
	# Applica la forza di rinculo e la fa decadere nel tempo
	if _kb_force > 0.0:
		_owner.velocity = _kb_direction * _kb_force
		_kb_force = move_toward(_kb_force, 0.0, kb_decay * delta)
	else:
		_owner.velocity = Vector2.ZERO
		
	_owner.move_and_slide()

## Chiamato dalla StateMachine quando si esce da questo stato.
func exit(_next_state: StringName = &"") -> void:
	# Disattiva il flag per interrompere eventuali 'await' pendenti e pulisce i vettori
	_active = false
	_kb_force = 0.0
	_kb_direction = Vector2.ZERO


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Determina il suffisso stringa della direzione basato su un vettore.
func _direction_to_suffix(dir: Vector2) -> String:
	# Se non c'è direzione, usa "down" di default
	if dir == Vector2.ZERO:
		return "down"
		
	# Sceglie l'asse dominante e restituisce la stringa associata
	if abs(dir.x) >= abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	else:
		return "down" if dir.y > 0.0 else "up"
