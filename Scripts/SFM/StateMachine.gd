extends Node
class_name FSM
# ==============================================================================
# SCRIPT: StateMachine.gd (FSM)
# DESCRIZIONE: Macchina a Stati Finita. Gestisce una collezione di nodi State 
# figli, delega loro i tick del motore (process, physics, input) e gestisce 
# in modo sicuro le transizioni tra di essi.
# ==============================================================================

# ------------------------------------------------------------------------------
# SEGNALI
# ------------------------------------------------------------------------------
signal state_changed(from: StringName, to: StringName)

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE
# ------------------------------------------------------------------------------
@export var initial_state: StringName = &""

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
var current_state: State
var states: Dictionary = {}

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _previous_state_name: StringName = &""


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	# Attende che il nodo proprietario sia pronto prima di inizializzare gli stati
	await owner.ready
	
	# Popola il dizionario degli stati cercando tra i nodi figli
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child._setup()
			
	# Avvia la macchina a stati: usa lo stato iniziale specificato se valido, 
	# altrimenti usa il primo stato figlio trovato.
	if initial_state != &"" and states.has(initial_state):
		_enter_state(initial_state, {})
	elif not states.is_empty():
		_enter_state(states.keys()[0], {})

func _process(delta: float) -> void:
	# Delega l'aggiornamento del frame allo stato corrente
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	# Delega l'aggiornamento fisico allo stato corrente
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	# Delega la gestione dell'input non processato allo stato corrente
	if current_state:
		current_state.handle_input(event)


# ==============================================================================
# METODI DI GESTIONE TRANSIZIONI
# ==============================================================================

## Cambia lo stato attivo della FSM.
## [data]: dizionario opzionale con parametri per il nuovo stato.
## Esempio: transition_to(&"Damaged", { "direction": kb_dir, "force": 200.0 })
func transition_to(state_name: StringName, data: Dictionary = {}, force: bool = false) -> void:
	if not states.has(state_name):
		push_error("FSM: stato '%s' non trovato." % state_name)
		return
		
	# Con force=true rientra nello stato ignorando se è già quello attivo
	if current_state != null and current_state.name == state_name and not force:
		return
		
	# Salva lo stato precedente per la funzione revert()
	_previous_state_name = current_state.name if current_state != null else &""
	
	# Esegue la logica di uscita dal vecchio stato
	if current_state != null:
		current_state.exit(state_name)
		
	# Emette il segnale del cambio di stato e avvia il nuovo
	state_changed.emit(_previous_state_name, state_name)
	_enter_state(state_name, data)

## Torna allo stato immediatamente precedente (se esistente).
func revert() -> void:
	if _previous_state_name != &"":
		transition_to(_previous_state_name)

## Restituisce il nome dello stato attualmente in esecuzione.
func get_current_state_name() -> StringName:
	return current_state.name if current_state != null else &""

## Controlla se un determinato stato è attualmente quello attivo.
func is_in_state(state_name: StringName) -> bool:
	return current_state != null and current_state.name == state_name


# ==============================================================================
# METODI DI SUPPORTO (PRIVATE)
# ==============================================================================

## Gestisce l'effettiva assegnazione e inizializzazione del nuovo stato.
func _enter_state(state_name: StringName, data: Dictionary) -> void:
	current_state = states[state_name]
	current_state.enter(_previous_state_name, data)
