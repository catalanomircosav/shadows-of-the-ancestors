extends CharacterBody2D
class_name EnemyBase

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var last_facing: String = "down"

func _ready() -> void:
	health.died.connect(_on_death)

func play_animation(anim_name: String, speed_scale: float = 1.0, force_restart: bool = false) -> void:
	
	if anim_player.has_animation(anim_name):
		anim_player.speed_scale = speed_scale
		if force_restart or anim_player.current_animation != anim_name:
			anim_player.stop()
			anim_player.play(anim_name)
			sprite.play(anim_name)

func _on_death() -> void:
	print("Il manichino è stato distrutto!")
	queue_free()
