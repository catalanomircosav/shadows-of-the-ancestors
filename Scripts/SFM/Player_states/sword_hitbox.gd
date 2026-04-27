# sword_hitbox.gd
extends Area2D
class_name SwordHitbox

var damage: int = 0
var knockback_strength: float = 0.0  # letto da Hurtbox
var _hit_this_swing: Array = []

func _ready() -> void:
	pass  # nessun segnale — è Hurtbox che ascolta

func enable() -> void:
	_hit_this_swing.clear()
	$CollisionShape2D.disabled = false

func disable() -> void:
	$CollisionShape2D.disabled = true

func already_hit(target: Node) -> bool:
	return target in _hit_this_swing

func register_hit(target: Node) -> void:
	_hit_this_swing.append(target)
