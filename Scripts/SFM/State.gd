## state.gd
## Classe base per tutti gli stati della FSM.
## Ogni stato concreto deve estendere questa classe.
extends Node
class_name State

## Riferimento alla StateMachine proprietaria.
## Viene assegnato automaticamente da PlayerStateMachine._ready().
var state_machine: PlayerStateMachine


## Chiamato una volta sola durante _ready() della StateMachine,
## dopo che tutti gli stati sono stati registrati.
func _setup() -> void:
	pass


## Chiamato quando si entra in questo stato.
## @param _previous_state: nome dello stato da cui si proviene.
func enter(_previous_state: StringName = &"") -> void:
	pass


## Chiamato ogni frame di fisica.
func physics_update(_delta: float) -> void:
	pass


## Chiamato ogni frame di logica (process).
func update(_delta: float) -> void:
	pass


## Chiamato quando si esce da questo stato.
## @param _next_state: nome dello stato verso cui si va.
func exit(_next_state: StringName = &"") -> void:
	pass


## Chiamato per input non gestiti da _unhandled_input.
func handle_input(_event: InputEvent) -> void:
	pass
