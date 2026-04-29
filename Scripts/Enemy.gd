extends CharacterBody2D
class_name EnemyBase
# ==============================================================================
# SCRIPT: Enemy.gd (EnemyBase)
# DESCRIZIONE: Classe base per i nemici. Gestisce riferimenti comuni, 
# la ricezione dei danni, la morte, le animazioni e la direzione dello sguardo.
# ==============================================================================

# ------------------------------------------------------------------------------
# NODI (ONREADY)
# ------------------------------------------------------------------------------
@onready var health: HealthComponent      = $HealthComponent
@onready var sprite: AnimatedSprite2D     = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: FSM           = $StateMachine

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
var last_facing: String = "down"
var noise_target_position: Vector2 = Vector2.ZERO  # Usato dallo stato Investigate
var debug_los_hit_pos: Vector2 = Vector2.ZERO
var debug_los_color: Color = Color.WHITE


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================
func _ready() -> void:
	# Connette i segnali emessi dall'HealthComponent
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)


# ==============================================================================
# CALLBACKS DEI SEGNALI
# ==============================================================================

## Invocato quando l'Enemy subisce un danno, gestendo il knockback.
func _on_damaged(kb_direction: Vector2, kb_force: float) -> void:
	# Usa call_deferred per aspettare la fine del frame fisico prima di cambiare stato e animazione
	state_machine.call_deferred("transition_to", &"Damaged", {
		"direction": kb_direction,
		"force":     kb_force
	}, true)

## Invocato quando la salute scende a zero. Rimanda l'esecuzione a fine frame.
func _on_death() -> void:
	call_deferred("_execute_death")

## Funzione separata che esegue effettivamente la logica di morte in sicurezza.
func _execute_death() -> void:
	# Chiama exit() sullo stato corrente così DamagedState 
	# chiama force_end_invincibility() prima di fermare la FSM
	if state_machine.current_state:
		state_machine.current_state.exit(&"Death")
	
	# Disattiva il processo della macchina a stati e ferma il movimento
	state_machine.set_physics_process(false)
	state_machine.set_process(false)
	velocity = Vector2.ZERO
	
	# Disabilita le collisioni fisiche in base a nomi prestabiliti
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	elif has_node("Collider"):
		$Collider.set_deferred("disabled", true)
		
	# Disabilita l'hurtbox per impedire ulteriori hit registrati
	if has_node("Hurtbox/CollisionShape2D"):
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	# Avvia l'animazione di morte, attende la sua fine e rimuove l'istanza
	play_animation("death", 1.0, true)
	await anim_player.animation_finished
	queue_free()


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

## Riproduce in parallelo un'animazione sia sull'AnimationPlayer che sullo Sprite.
func play_animation(anim_name: String, speed_scale: float = 1.0, force_restart: bool = false) -> void:
	if not anim_player.has_animation(anim_name):
		push_warning("EnemyBase: animazione '%s' non trovata." % anim_name)
		return
		
	anim_player.speed_scale = speed_scale
	
	# Riavvia l'animazione se richiesto o se è diversa da quella corrente
	if force_restart or anim_player.current_animation != anim_name:
		anim_player.stop()
		anim_player.play(anim_name)
		sprite.play(anim_name)

## Aggiorna la variabile di stato della direzione in base al vettore di input.
func update_facing_direction(direction: Vector2) -> void:
	# Controlla se il movimento è prevalentemente orizzontale o verticale (risolve il bug delle diagonali)
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0.0:
			last_facing = "right"
		else:
			last_facing = "left"
	else:
		if direction.y > 0.0:
			last_facing = "down"
		else:
			last_facing = "up"
			
func _process(_delta: float) -> void:
	# Forza Godot a ridisegnare la grafica ad ogni frame
	queue_redraw()

func _draw() -> void:
	if not state_machine or not state_machine.current_state:
		return
		
	var state_name = state_machine.current_state.name
	
	# 1. Disegna il nome dello stato sopra la testa del nemico
	draw_string(ThemeDB.fallback_font, Vector2(-25, -40), state_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.YELLOW)
	
	# 2. Se sta inseguendo, disegna il raggio visivo
	if state_name == "Chase":
		# to_local() serve perché il disegno avviene nello spazio locale del nemico
		draw_line(Vector2.ZERO, to_local(debug_los_hit_pos), debug_los_color, 2.0)
		draw_circle(to_local(debug_los_hit_pos), 4.0, debug_los_color)
		
	# 3. Se sta investigando, disegna una linea verso la sorgente del rumore
	if state_name == "Investigate" and noise_target_position != Vector2.ZERO:
		draw_line(Vector2.ZERO, to_local(noise_target_position), Color.CYAN, 1.5)
		draw_circle(to_local(noise_target_position), 4.0, Color.BLUE)
		
## Lancia un raggio invisibile per capire se c'è un ostacolo tra il nemico e un bersaglio.
func has_line_of_sight(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		debug_los_hit_pos = result.position
		if result.collider.is_in_group("player"):
			debug_los_color = Color.GREEN
			return true
		else:
			debug_los_color = Color.RED
			return false
			
	debug_los_hit_pos = target.global_position
	debug_los_color = Color.GREEN
	return true
