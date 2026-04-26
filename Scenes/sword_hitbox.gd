extends Area2D
class_name SwordHitbox

var damage: int = 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	
	if enemy != null and enemy.has_node("HealthComponent"):
		var enemy_health = enemy.get_node("HealthComponent") as HealthComponent
		
		enemy_health.take_damage(damage)
		print("Colpito! Danno inflitto: ", damage, " | Vita rimanente: ", enemy_health.current_health)
