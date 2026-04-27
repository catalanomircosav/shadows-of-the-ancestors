extends Node
class_name FSM

signal state_changed(from: StringName, to: StringName)

@export var initial_state: StringName = &""

var current_state: State
var states: Dictionary = {}
var _previous_state_name: StringName = &""

func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child._setup()
	if initial_state != &"" and states.has(initial_state):
		_enter_state(initial_state, {})
	elif not states.is_empty():
		_enter_state(states.keys()[0], {})

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

## data: dizionario opzionale con parametri per il nuovo stato.
## Esempio: transition_to(&"Damaged", { "direction": kb_dir, "force": 200.0 })
func transition_to(state_name: StringName, data: Dictionary = {}, force: bool = false) -> void:
	if not states.has(state_name):
		push_error("FSM: stato '%s' non trovato." % state_name)
		return
	# Con force=true rientra nello stato anche se è già attivo
	if current_state != null and current_state.name == state_name and not force:
		return
	_previous_state_name = current_state.name if current_state != null else &""
	if current_state != null:
		current_state.exit(state_name)
	state_changed.emit(_previous_state_name, state_name)
	_enter_state(state_name, data)

func revert() -> void:
	if _previous_state_name != &"":
		transition_to(_previous_state_name)

func get_current_state_name() -> StringName:
	return current_state.name if current_state != null else &""

func is_in_state(state_name: StringName) -> bool:
	return current_state != null and current_state.name == state_name

func _enter_state(state_name: StringName, data: Dictionary) -> void:
	current_state = states[state_name]
	current_state.enter(_previous_state_name, data)
