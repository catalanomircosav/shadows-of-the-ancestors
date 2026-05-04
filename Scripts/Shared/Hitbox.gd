extends Area2D
class_name Hitbox
# ==============================================================================
# SCRIPT: hitbox.gd (Ex SwordHitbox)
# DESCRIZIONE: Componente universale per le aree di collisione offensive.
# Funziona sia per il Player che per i Nemici. Tiene traccia delle entità 
# colpite per evitare danni multipli nello stesso attacco.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE (Modificabili dall'editor per ogni entità)
# ------------------------------------------------------------------------------
signal hit_landed(target: Node)
@export var damage: int = 10
@export var knockback_strength: float = 200.0 

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
# Riferimento all'entità che sta sferrando l'attacco (utile all'Hurtbox per il backstab)
var attacker: Node

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _hit_this_swing: Array = []


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	# Assume che il genitore (o un nonno) sia l'entità che attacca.
	# Se l'albero è Entità -> Hitbox, get_parent() va benissimo.
	# Se è Entità -> Attacchi -> Hitbox, potresti usare get_parent().get_parent() o owner.
	attacker = get_parent()


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Abilita l'hitbox all'inizio di un colpo e svuota la lista dei bersagli colpiti.
func enable() -> void:
	_hit_this_swing.clear()
	$CollisionShape2D.disabled = false

## Disabilita l'hitbox alla fine di un colpo, terminando i danni.
func disable() -> void:
	$CollisionShape2D.disabled = true

## Verifica se un determinato bersaglio (nodo) è già stato colpito durante questo attacco.
func already_hit(target: Node) -> bool:
	return target in _hit_this_swing

## Registra un bersaglio nella lista di quelli colpiti per ignorarlo ai frame successivi.
func register_hit(target: Node) -> void:
	_hit_this_swing.append(target)
	hit_landed.emit(target)
