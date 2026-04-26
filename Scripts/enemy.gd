extends CharacterBody2D
class_name EnemyBase

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine = $StateMachine

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
	if state_machine:
		state_machine.set_physics_process(false)
	
	velocity = Vector2.ZERO
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	elif has_node("Collider"):
		$Collider.set_deferred("disabled", true)
		
	if has_node("Hurtbox/CollisionShape2D"):
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

	play_animation("death", 1.0, true)
	
	await anim_player.animation_finished
	queue_free()
