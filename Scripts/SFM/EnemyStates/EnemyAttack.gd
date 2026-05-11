extends State
class_name EnemyAttackState
# ==============================================================================
# SCRIPT: enemy_attack.gd
# DESCRIZIONE: Stato di attacco del nemico. Ferma il movimento, si gira verso
# il giocatore e riproduce l'animazione di attacco. Si affida all'AnimationPlayer
# per abilitare/disabilitare le hitbox fisiche durante i frame attivi.
# Al termine dell'animazione, torna in Chase (che deciderà se ri-attaccare).
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _enemy: EnemyBase
var _player: Player


# ==============================================================================
# METODI DI INIZIALIZZAZIONE DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine per inizializzare i riferimenti.
func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase


# ==============================================================================
# METODI DEL CICLO DI VITA DELLO STATO
# ==============================================================================

## Chiamato dalla StateMachine quando si entra in questo stato.
func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	
	# Azzera la velocità: il nemico non deve scivolare mentre attacca
	_enemy.velocity = Vector2.ZERO
	
	# Se il player esiste ancora, si gira verso di lui all'ultimo istante utile
	if is_instance_valid(_player):
		var dir_to_player: Vector2 = _enemy.global_position.direction_to(_player.global_position)
		_enemy.update_facing_direction(dir_to_player)
	
	# Avvia l'animazione di attacco basata sulla direzione
	_enemy.play_animation("attack_" + _enemy.last_facing, 1.0, true)
	
	# Connette il segnale di fine animazione per sapere quando l'attacco è concluso
	if not _enemy.anim_player.animation_finished.is_connected(_on_animation_finished):
		_enemy.anim_player.animation_finished.connect(_on_animation_finished)
	
	get_tree().call_group("music_manager", "allerta_nemico")

## Chiamato dalla StateMachine quando si esce da questo stato (es. se subisce danni e passa in Damaged).
func exit(_next_state: StringName = &"") -> void:
	# Disconnette il segnale in modo sicuro per evitare memory leak o esecuzioni errate
	if _enemy.anim_player.animation_finished.is_connected(_on_animation_finished):
		_enemy.anim_player.animation_finished.disconnect(_on_animation_finished)
		
	get_tree().call_group("music_manager", "calma_nemico")

## Chiamato dalla StateMachine ad ogni frame fisico.
func physics_update(_delta: float) -> void:
	# Mantiene il nemico fermo, ma chiama move_and_slide() in caso
	# debbano essere applicate forze esterne (es. spintoni da altri nemici)
	_enemy.velocity = Vector2.ZERO
	_enemy.move_and_slide()


# ==============================================================================
# CALLBACKS DEI SEGNALI
# ==============================================================================

## Chiamato automaticamente quando l'AnimationPlayer termina un'animazione.
func _on_animation_finished(anim_name: String) -> void:
	# Verifica che l'animazione terminata sia effettivamente quella di attacco
	if anim_name.begins_with("attack_"):
		# Se il player è stato distrutto durante l'attacco, torna in Idle
		if not is_instance_valid(_player):
			state_machine.transition_to(&"Idle")
			return
			
		# Torna allo stato Chase. Lo script di Chase calcolerà immediatamente
		# la distanza: se il player è ancora a tiro (<= 25.0), rientrerà
		# istantaneamente in Attack sferrando un altro colpo.
		state_machine.transition_to(&"Chase")
