extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	anim.play("abbassato")
	collision.set_deferred("disabled", true)

func chiudi() -> void:
	anim.play("chiusura")
	collision.set_deferred("disabled", false)
	
func apri() -> void:
	anim.play_backwards("chiusura")
	collision.set_deferred("disabled", true)
