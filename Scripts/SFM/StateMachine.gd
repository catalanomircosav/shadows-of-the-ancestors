class_name PlayerStateMachine
extends Node

signal state_changed(from: StringName, to: StringName)

@export var initial_state: StringName = &""

var current_state: State
var states: Dictionary = { } # StringName -> State
var _previous_state_name: StringName = &""

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child._setup()

	if initial_state != &"" and states.has(initial_state):
		_enter_state(initial_state)
	elif get_child_count() > 0:
		_enter_state(get_child(0).name)

func _process(_delta: float) -> void:
	if current_state:
		current_state.update(_delta)

func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.physics_update(_delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
		
func transition_to(state_name: StringName) -> void:
	if not states.has(state_name):
		push_error("StateMachine: stato '%s' non trovato." % state_name)
		return
	if current_state and current_state.name == state_name:
		return
	
	_previous_state_name = current_state.name if current_state else &""
	
	if current_state: current_state.exit(state_name)
	
	emit_signal("state_changed", _previous_state_name, state_name)
	_enter_state(state_name)

# torna allo stato precedente (per attacchi, ecc)
func revert() -> void:
	if _previous_state_name != &"":
		transition_to(_previous_state_name)
		
func get_current_state_name() -> StringName:
	return current_state.name if current_state else &""

func is_in_state(state_name: StringName) -> bool:
	return current_state != null and current_state.name == state_name
	
func _enter_state(state_name: StringName) -> void:
	current_state = states[state_name]
	current_state.enter(_previous_state_name)
