extends Node
class_name HealthComponent
# ==============================================================================
# SCRIPT: HealthComponent.gd
# DESCRIZIONE: Componente riutilizzabile per gestire la salute, i danni, 
# i periodi di invulnerabilità (i-frames) e l'emissione dei segnali di morte
# o di rinculo (knockback).
# ==============================================================================

# ------------------------------------------------------------------------------
# SEGNALI
# ------------------------------------------------------------------------------
signal health_changed(current_health: int, max_health: int)
signal damaged(knockback_direction: Vector2, knockback_force: float)
signal died

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE
# ------------------------------------------------------------------------------
@export var max_health: int = 100
@export var invincibility_duration: float = 0.6
@export var knockback_force: float = 200.0

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
var current_health: int
var is_invincible: bool = false

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _iframe_timer: Timer


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	current_health = max_health
	
	# Crea e configura dinamicamente il timer per i frame di invulnerabilità
	_iframe_timer = Timer.new()
	_iframe_timer.one_shot = true
	_iframe_timer.timeout.connect(_on_iframe_expired)
	add_child(_iframe_timer)


# ==============================================================================
# METODI PUBBLICI (API DEL COMPONENTE)
# ==============================================================================

## Applica un danno all'entità, gestendo l'invincibilità e calcolando il knockback.
func take_damage(
		amount: int, 
		damage_source_position: Vector2 = Vector2.ZERO, 
		custom_knockback_force: float = 0.0) -> void:
			
	if is_dead():
		return
	if is_invincible:
		return

	# Sottrae la salute mantenendola nei limiti corretti (0 - max_health)
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)

	# Se il colpo è letale, emette il segnale di morte e interrompe l'elaborazione
	if is_dead():
		is_invincible = false  # Reset per sicurezza
		died.emit()
		return

	# --- Calcolo del vettore di Knockback ---
	var kb_dir: Vector2 = Vector2.ZERO
	var owner_body: Node = get_parent()
	
	if damage_source_position != Vector2.ZERO and owner_body is Node2D:
		# Calcola la direzione grezza rispetto alla fonte del danno
		var raw: Vector2 = (owner_body.global_position - damage_source_position).normalized()
		
		# Forza il vettore ad essere rigidamente ortogonale (solo su, giù, sx, dx)
		if abs(raw.x) >= abs(raw.y):
			kb_dir = Vector2(sign(raw.x), 0.0)
		else:
			kb_dir = Vector2(0.0, sign(raw.y))

	# Assegna la forza di rinculo (personalizzata o predefinita)
	var kb_force: float = custom_knockback_force if custom_knockback_force > 0.0 else knockback_force

	# NON avviare il timer qui — lo fa DamagedState tramite start_invincibility()
	damaged.emit(kb_dir, kb_force)

## Ripristina parte della salute persa, senza superare il limite massimo.
func heal(amount: int) -> void:
	if is_dead():
		return
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)

## Restituisce 'true' se l'entità ha esaurito i punti salute.
func is_dead() -> bool:
	return current_health <= 0

## Chiamato da DamagedState.enter() — iframe ON per tutta la durata dell'animazione.
func start_invincibility() -> void:
	is_invincible = true

## Chiamato da DamagedState.exit() — iframe OFF (forza la disattivazione).
func force_end_invincibility() -> void:
	_iframe_timer.stop()
	is_invincible = false


# ==============================================================================
# METODI PRIVATI INTERNI
# ==============================================================================

## Avvia il timer di invulnerabilità basato sul valore 'invincibility_duration'.
## NOTA: Attualmente orfano, non viene chiamato nel flusso corrente.
func _start_invincibility() -> void:
	is_invincible = true
	_iframe_timer.start(invincibility_duration)

## Callback del timer: disattiva l'invulnerabilità una volta scaduto il tempo.
func _on_iframe_expired() -> void:
	is_invincible = false
