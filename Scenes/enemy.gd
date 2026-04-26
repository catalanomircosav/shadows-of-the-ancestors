extends CharacterBody2D

@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
	health.died.connect(_on_death)


func _on_death() -> void:
	print("Il manichino è stato distrutto!")
	queue_free()
