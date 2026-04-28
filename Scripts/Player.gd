extends CharacterBody2D
class_name Player

@export var acceleration: float = 80.0
@export var friction: float     = 100.0
@export var max_speed: float    = 190.0
@export var run_speed: float    = 304.0
@export var damaged_mult: float = 1.0

var move_direction: Vector2 = Vector2.ZERO
var last_facing: String = "down"

@onready var anim_player: AnimationPlayer  = $AnimationPlayer
@onready var sprite: AnimatedSprite2D      = $AnimatedSprite2D
@onready var sword_hitbox: Hitbox     = $SwordHitbox
@onready var health: HealthComponent       = $HealthComponent
@onready var state_machine: FSM   = $StateMachine

var light_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("player")
	VisibilityManager.register_player(self)
	NoiseManager.register_player(self)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)

func _on_damaged(kb_direction: Vector2, kb_force: float) -> void:
	state_machine.call_deferred("transition_to", &"Damaged", {
		"direction": kb_direction,
		"force":     kb_force * damaged_mult
	})

func _on_death() -> void:
	state_machine.set_physics_process(false)
	state_machine.set_process(false)
	velocity = Vector2.ZERO
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hurtbox/CollisionShape2D"):
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	play_animation("death", 1.0, true)
	await anim_player.animation_finished
	queue_free()

func update_facing_direction(direction: Vector2) -> void:
	if direction.x > 0.0:
		last_facing = "right"
	elif direction.x < 0.0:
		last_facing = "left"
	elif direction.y > 0.0:
		last_facing = "down"
	elif direction.y < 0.0:
		last_facing = "up"

func play_animation(anim_name: String, speed_scale: float = 1.0, force_restart: bool = false) -> void:
	anim_player.speed_scale = speed_scale
	if force_restart or anim_player.current_animation != anim_name:
		anim_player.stop()
		anim_player.play(anim_name)
		sprite.play(anim_name)
