extends Node
class_name State

var state_machine: FSM

func _setup() -> void:
	pass

## _data: dizionario con parametri contestuali passati da transition_to().
## Le sottoclassi che non lo usano dichiarano il parametro con _ per ignorarlo.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func exit(_next_state: StringName = &"") -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
