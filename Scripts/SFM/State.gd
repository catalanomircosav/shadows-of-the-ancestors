class_name State
extends Node2D

var state_machine

func _setup() -> void:
	pass
	
func enter(previous_state: StringName = &"") -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass

func update(delta: float) -> void:
	pass

func exit(next_state: StringName = &"") -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
