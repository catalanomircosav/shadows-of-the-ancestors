extends Area2D

# Questo creerà uno slot nell'Ispettore dove trascinerai il tuo KingSlime
@export var boss_node: CharacterBody2D 
@export var sbarre_arena: StaticBody2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sbarre_arena and sbarre_arena.has_method("chiudi"):
			sbarre_arena.chiudi()
		if boss_node and boss_node.has_method("avvia_boss"):
			boss_node.avvia_boss()
			set_deferred("monitoring", false)
			
func _ready() -> void:
	if boss_node and boss_node.has_node("HealthComponent"):
		var boss_health = boss_node.get_node("HealthComponent")
		
		if not boss_health.died.is_connected(_on_boss_died):
			boss_health.died.connect(_on_boss_died)

func _on_boss_died() -> void:
	if sbarre_arena and sbarre_arena.has_method("apri"):
		sbarre_arena.apri()
