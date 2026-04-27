extends Node
class_name State
# ==============================================================================
# SCRIPT: State.gd
# DESCRIZIONE: Classe base virtuale per tutti gli stati della Macchina a Stati.
# Definisce l'interfaccia e i metodi del ciclo di vita che le classi figlie 
# dovranno sovrascrivere (override) per implementare logiche specifiche.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
## Riferimento alla Macchina a Stati che gestisce questo nodo. 
## Viene iniettato automaticamente da FSM durante il setup iniziale.
var state_machine: FSM


# ==============================================================================
# METODI VIRTUALI (Da sovrascrivere nelle classi figlie)
# ==============================================================================

## Chiamato dalla StateMachine subito dopo aver assegnato il riferimento
## 'state_machine'. Utile per inizializzare nodi (es. cast del Player o dell'Enemy).
func _setup() -> void:
	pass

## Chiamato quando la FSM entra in questo stato.
## [_previous_state]: Il nome dello stato da cui si proviene.
## [_data]: Dizionario con parametri contestuali passati da transition_to().
## Le sottoclassi che non usano questi parametri devono dichiararli con '_' per ignorarli.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	pass

## Chiamato dalla FSM ad ogni frame fisico (agganciato a _physics_process).
## Utile per gestire il movimento, le collisioni e le logiche pesanti.
func physics_update(_delta: float) -> void:
	pass

## Chiamato dalla FSM ad ogni frame di rendering (agganciato a _process).
## Utile per aggiornare timer, animazioni o logiche visive.
func update(_delta: float) -> void:
	pass

## Chiamato dalla FSM immediatamente prima di passare a un nuovo stato.
## Utile per pulire variabili, resettare animazioni o disabilitare hitbox.
func exit(_next_state: StringName = &"") -> void:
	pass

## Chiamato dalla FSM per propagare gli input non gestiti (agganciato a _unhandled_input).
func handle_input(_event: InputEvent) -> void:
	pass
