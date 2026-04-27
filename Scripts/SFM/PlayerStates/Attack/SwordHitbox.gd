extends Area2D
class_name SwordHitbox
# ==============================================================================
# SCRIPT: sword_hitbox.gd (SwordHitbox)
# DESCRIZIONE: Componente che gestisce l'area di collisione offensiva della spada.
# Tiene traccia delle entità colpite in un singolo fendente per evitare di
# applicare danni multipli nello stesso colpo.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
var damage: int = 0
var knockback_strength: float = 0.0  # Letto dal componente Hurtbox per il rinculo

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _hit_this_swing: Array = []


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	pass  # Nessun segnale collegato qui — è l'Hurtbox che ascolta le collisioni


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Abilita l'hitbox all'inizio di un fendente e svuota la lista dei bersagli colpiti.
func enable() -> void:
	_hit_this_swing.clear()
	$CollisionShape2D.disabled = false

## Disabilita l'hitbox alla fine di un fendente, terminando i danni.
func disable() -> void:
	$CollisionShape2D.disabled = true

## Verifica se un determinato bersaglio (nodo) è già stato colpito durante questo fendente.
func already_hit(target: Node) -> bool:
	return target in _hit_this_swing

## Registra un bersaglio nella lista di quelli colpiti per ignorarlo ai frame successivi.
func register_hit(target: Node) -> void:
	_hit_this_swing.append(target)
