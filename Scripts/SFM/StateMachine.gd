## Macchina a stati finiti generica per il Player.
## Registra automaticamente tutti i nodi figli di tipo State.
extends Node
class_name PlayerStateMachine

## Emesso ad ogni transizione di stato.
signal state_changed(from: StringName, to: StringName)

## Nome dello stato iniziale. Se vuoto, usa il primo figlio.
@export var initial_state: StringName = &""

var current_state: State
var states: Dictionary = {}        # StringName → State
var _previous_state_name: StringName = &""


func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child._setup()

	if initial_state != &"" and states.has(initial_state):
		_enter_state(initial_state)
	elif not states.is_empty():
		_enter_state(states.keys()[0])


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


## Transisce allo stato indicato per nome.
## Non fa nulla se lo stato è già attivo.
func transition_to(state_name: StringName) -> void:
	print("Stato '%s'" % state_name)
	if not states.has(state_name):
		push_error("PlayerStateMachine: stato '%s' non trovato." % state_name)
		return

	if current_state != null and current_state.name == state_name:
		return

	_previous_state_name = current_state.name if current_state != null else &""

	if current_state != null:
		current_state.exit(state_name)

	state_changed.emit(_previous_state_name, state_name)
	_enter_state(state_name)


## Torna allo stato precedente.
## Utile per stati temporanei come Attack o Stagger.
func revert() -> void:
	if _previous_state_name != &"":
		transition_to(_previous_state_name)


## Restituisce il nome dello stato corrente.
func get_current_state_name() -> StringName:
	return current_state.name if current_state != null else &""


## Restituisce true se la macchina è nello stato indicato.
func is_in_state(state_name: StringName) -> bool:
	return current_state != null and current_state.name == state_name


# ── privato ────────────────────────────────────────────────────────────────

func _enter_state(state_name: StringName) -> void:
	current_state = states[state_name]
	current_state.enter(_previous_state_name)
