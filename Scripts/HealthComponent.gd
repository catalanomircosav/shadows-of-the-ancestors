extends Node
class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal damaged(knockback_direction: Vector2, knockback_force: float)
signal died

@export var max_health: int = 100
@export var invincibility_duration: float = 0.6
@export var knockback_force: float = 200.0

var current_health: int
var is_invincible: bool = false

var _iframe_timer: Timer

func _ready() -> void:
	current_health = max_health
	_iframe_timer = Timer.new()
	_iframe_timer.one_shot = true
	_iframe_timer.timeout.connect(_on_iframe_expired)
	add_child(_iframe_timer)

func take_damage(
		amount: int,
		damage_source_position: Vector2 = Vector2.ZERO,
		custom_knockback_force: float = 0.0) -> void:

	if is_dead():
		return
	if is_invincible:
		return

	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)

	if is_dead():
		is_invincible = false  # reset per sicurezza
		died.emit()
		return

	var kb_dir := Vector2.ZERO
	var owner_body := get_parent()
	if damage_source_position != Vector2.ZERO and owner_body is Node2D:
		var raw = (owner_body.global_position - damage_source_position).normalized()
		if abs(raw.x) >= abs(raw.y):
			kb_dir = Vector2(sign(raw.x), 0.0)
		else:
			kb_dir = Vector2(0.0, sign(raw.y))

	var kb_force := custom_knockback_force if custom_knockback_force > 0.0 else knockback_force

	# NON avviare il timer qui — lo fa DamagedState tramite start_invincibility()
	damaged.emit(kb_dir, kb_force)

func heal(amount: int) -> void:
	if is_dead():
		return
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

## Chiamato da DamagedState.enter() — iframe ON per tutta la durata dell'animazione
func start_invincibility() -> void:
	is_invincible = true

## Chiamato da DamagedState.exit() — iframe OFF
func force_end_invincibility() -> void:
	_iframe_timer.stop()
	is_invincible = false

func _start_invincibility() -> void:
	is_invincible = true
	_iframe_timer.start(invincibility_duration)

func _on_iframe_expired() -> void:
	is_invincible = false
