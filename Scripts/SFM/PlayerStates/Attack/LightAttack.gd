extends AttackBase
class_name LightAttackState
# ==============================================================================
# SCRIPT: light_attack.gd (LightAttackState)
# DESCRIZIONE: Stato specifico per l'attacco leggero. Eredita tutta la logica
# di movimento, hitbox e transizione da AttackBase, fornendo solo il prefisso
# corretto per l'animazione.
# ==============================================================================

# ==============================================================================
# METODI SOVRASCRITTI (OVERRIDES)
# ==============================================================================

## Sovrascrive il metodo di AttackBase per restituire il prefisso dell'animazione
## specifica dell'attacco leggero.
func _get_anim_prefix() -> String:
	return "light_attack"
