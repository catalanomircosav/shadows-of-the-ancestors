extends AttackBase
class_name HeavyAttackState
# ==============================================================================
# SCRIPT: heavy_attack.gd (HeavyAttackState)
# DESCRIZIONE: Stato specifico per l'attacco pesante. Eredita tutta la logica
# di movimento, hitbox e transizione da AttackBase, fornendo solo il prefisso
# corretto per l'animazione.
# ==============================================================================

# ==============================================================================
# METODI SOVRASCRITTI (OVERRIDES)
# ==============================================================================

## Sovrascrive il metodo di AttackBase per restituire il prefisso dell'animazione
## specifica dell'attacco pesante.
func _get_anim_prefix() -> String:
	return "heavy_attack"
	
func enter(previous_state: StringName = &"", data: Dictionary = {}) -> void:
	super.enter(previous_state, data)
	
	_player.play_sfx("SfxPowerAttack")
