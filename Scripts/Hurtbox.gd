# hurtbox.gd
extends Area2D
class_name Hurtbox

@onready var health_component: HealthComponent = get_parent().get_node("HealthComponent")

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area2D) -> void:
	
	if not hitbox is SwordHitbox:
		return

	var owner_node := get_parent()
	if hitbox.already_hit(owner_node):
		return
	hitbox.register_hit(owner_node)
	health_component.take_damage(hitbox.damage, hitbox.global_position, hitbox.knockback_strength)
