extends AttackBase
class_name LightAttackState
# ==============================================================================
# SCRIPT: light_attack.gd (LightAttackState)
# ==============================================================================

# ==============================================================================
# METODI SOVRASCRITTI (OVERRIDES)
# ==============================================================================

## Sovrascrive il metodo di AttackBase per restituire il prefisso dell'animazione
func _get_anim_prefix() -> String:
	return "light_attack"

## Sovrascrive l'enter per aggiungere il suono, mantenendo la logica del padre
func enter(previous_state: StringName = &"", data: Dictionary = {}) -> void:
	# 1. Esegue tutta la logica di base (hitbox, animazione) scritta in AttackBase
	super.enter(previous_state, data)
	
	# 2. Fa partire il suono usando la variabile ereditata dal padre!
	_player.play_sfx("SfxSwing")
