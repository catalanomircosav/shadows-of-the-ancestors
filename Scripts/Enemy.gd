extends CharacterBody2D
class_name EnemyBase

@onready var health: HealthComponent      = $HealthComponent
@onready var sprite: AnimatedSprite2D     = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: FSM           = $StateMachine

var last_facing: String = "down"
var noise_target_position: Vector2 = Vector2.ZERO  # usato da Suspicious/Investigate

func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)

# ── Segnali HealthComponent ────────────────────────────────────────────────

func _on_damaged(kb_direction: Vector2, kb_force: float) -> void:
	state_machine.transition_to(&"Damaged", {
		"direction": kb_direction,
		"force":     kb_force
	}, true)

func _on_death() -> void:
	# Chiama exit() sullo stato corrente così DamagedState
	# chiama force_end_invincibility() prima di fermare la FSM
	if state_machine.current_state:
		state_machine.current_state.exit(&"Death")

	state_machine.set_physics_process(false)
	state_machine.set_process(false)
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

# ── Helpers ────────────────────────────────────────────────────────────────

func play_animation(anim_name: String, speed_scale: float = 1.0, force_restart: bool = false) -> void:
	if not anim_player.has_animation(anim_name):
		push_warning("EnemyBase: animazione '%s' non trovata." % anim_name)
		return
	anim_player.speed_scale = speed_scale
	if force_restart or anim_player.current_animation != anim_name:
		anim_player.stop()
		anim_player.play(anim_name)
		sprite.play(anim_name)

func update_facing_direction(direction: Vector2) -> void:
	if direction.x > 0.0:
		last_facing = "right"
	elif direction.x < 0.0:
		last_facing = "left"
	elif direction.y > 0.0:
		last_facing = "down"
	elif direction.y < 0.0:
		last_facing = "up"
