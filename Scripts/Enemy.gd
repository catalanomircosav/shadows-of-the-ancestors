extends CharacterBody2D
class_name EnemyBase
# ==============================================================================
# SCRIPT: Enemy.gd (EnemyBase)
# DESCRIZIONE: Classe base per i nemici. Gestisce riferimenti comuni, 
# la ricezione dei danni, la morte, le animazioni, la direzione dello sguardo
# e l'aggiornamento della barra della vita (se presente).
# ==============================================================================

# ------------------------------------------------------------------------------
# NODI (ONREADY)
# ------------------------------------------------------------------------------
@onready var health: HealthComponent      = $HealthComponent
@onready var sprite: AnimatedSprite2D     = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: FSM           = $StateMachine

# Cerca la barra della vita. Usa get_node_or_null così non crasha se a un nemico manca.
@onready var health_bar: TextureProgressBar = get_node_or_null("TextureProgressBar")

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE E COSTANTI
# ------------------------------------------------------------------------------
var last_facing: String = "down"
var noise_target_position: Vector2 = Vector2.ZERO  # Usato dallo stato Investigate
var debug_los_hit_pos: Vector2 = Vector2.ZERO
var debug_los_color: Color = Color.WHITE

const FOV_ANGLE: float = 140.0 # Angolo del cono visivo in gradi
const INSTA_DETECT_RADIUS: float = 4.0 # Distanza per rilevamento tattile (schiene)


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================
func _ready() -> void:
	# Connette i segnali emessi dall'HealthComponent per danni e morte
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)
	
	# Se il tuo HealthComponent ha un segnale che trasmette i cambi di vita, collegalo:
	if health.has_signal("health_changed"):
		health.health_changed.connect(_on_health_changed)
	
	# Configura la barra della vita all'avvio
	if health_bar:
		health_bar.max_value = health.max_health
		health_bar.value = health.max_health


# ==============================================================================
# CALLBACKS DEI SEGNALI
# ==============================================================================

func _on_damaged(kb_direction: Vector2, kb_force: float) -> void:
	if health_bar and not health.has_signal("health_changed"):
		_on_health_changed(health.current_health, health.max_health)
		
	state_machine.call_deferred("transition_to", &"Damaged", {
		"direction": kb_direction,
		"force":     kb_force
	}, true)

func _on_health_changed(current_hp: int, _max_hp: int) -> void:
	if not health_bar:
		return
		
	health_bar.value = current_hp
	if current_hp < health.max_health and current_hp > 0:
		health_bar.show()

func _on_death() -> void:
	call_deferred("_execute_death")

func _execute_death() -> void:
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
		
	if health_bar:
		health_bar.hide()
	
	var anim_morte: String = "death_" + last_facing
	
	if anim_player.has_animation(anim_morte):
		play_animation(anim_morte, 1.0, true)
	else:
		push_warning("EnemyBase: Animazione '%s' non trovata. Uso 'death' di default." % anim_morte)
		play_animation("death", 1.0, true)
		
	await anim_player.animation_finished
	queue_free()


# ==============================================================================
# METODI DI SUPPORTO (HELPERS)
# ==============================================================================

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
	# Ignoriamo i vettori nulli per non sovrascrivere l'ultimo facing valido
	if direction.length_squared() < 0.01:
		return

	# Calcoliamo l'asse dominante in modo netto
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
	queue_redraw()

func _draw() -> void:
	if not state_machine or not state_machine.current_state:
		return
		
	var state_name = state_machine.current_state.name
	
	# Disegna il nome dello stato
	draw_string(ThemeDB.fallback_font, Vector2(-25, -40), state_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.YELLOW)
	
	if state_name == "Chase":
		draw_line(Vector2.ZERO, to_local(debug_los_hit_pos), debug_los_color, 2.0)
		draw_circle(to_local(debug_los_hit_pos), 4.0, debug_los_color)
		
	if state_name == "Investigate" and noise_target_position != Vector2.ZERO:
		draw_line(Vector2.ZERO, to_local(noise_target_position), Color.CYAN, 1.5)
		draw_circle(to_local(noise_target_position), 4.0, Color.BLUE)

	# --- DEBUG: DISEGNA IL CONO VISIVO ---
	var facing_vector: Vector2 = Vector2.DOWN
	match last_facing:
		"up":    facing_vector = Vector2.UP
		"down":  facing_vector = Vector2.DOWN
		"left":  facing_vector = Vector2.LEFT
		"right": facing_vector = Vector2.RIGHT
		
	var fov_rad = deg_to_rad(FOV_ANGLE)
	# Crea le due linee laterali del campo visivo
	var left_edge = facing_vector.rotated(-fov_rad / 2.0) * 110
	var right_edge = facing_vector.rotated(fov_rad / 2.0) * 110
	
	# Disegna i bordi in verde trasparente
	draw_line(Vector2.ZERO, left_edge, Color(0.0, 1.0, 0.0, 0.4), 2.0)
	draw_line(Vector2.ZERO, right_edge, Color(0.0, 1.0, 0.0, 0.4), 2.0)

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


# ==============================================================================
# LOGICA DI VISIONE CON CONO VISIVO (FOV E STEALTH)
# ==============================================================================

## Restituisce true se il player è nel cono visivo, abbastanza vicino e visibile.
func can_see_player(player: Player, base_vision_range: float) -> bool:
	var dist_to_player: float = global_position.distance_to(player.global_position)
	
	# 1. VANTAGGIO STEALTH (Crouch riduce SOLO la visibilità a distanza)
	var actual_range: float = base_vision_range
	
	if player.state_machine and player.state_machine.current_state:
		if player.state_machine.current_state.name == "Crouch":
			actual_range *= 0.55 # Sei il 45% più difficile da individuare da lontano
		
	# Lontano dal raggio (scalato dal buio e dal crouch)
	if dist_to_player > actual_range:
		return false
		
	# 2. PROSSIMITÀ ESTREMA (Ci sei sbattuto contro)
	# Ora scatterà solo se la distanza è 4.0 o meno!
	if dist_to_player <= INSTA_DETECT_RADIUS:
		return has_line_of_sight(player)
		
	# 3. CONO VISIVO (FOV)
	var facing_vector: Vector2 = Vector2.DOWN
	match last_facing:
		"up":    facing_vector = Vector2.UP
		"down":  facing_vector = Vector2.DOWN
		"left":  facing_vector = Vector2.LEFT
		"right": facing_vector = Vector2.RIGHT
		
	# FIX: Trasformiamo il vettore "locale" in una direzione "globale" 
	# Questo risolve qualsiasi problema se il nodo del nemico è stato scalato (es. -1) o ruotato!
	var global_facing: Vector2 = to_global(facing_vector) - global_position
	global_facing = global_facing.normalized()
		
	var dir_to_player: Vector2 = global_position.direction_to(player.global_position)
	var angle_diff: float = rad_to_deg(abs(global_facing.angle_to(dir_to_player)))
	
	# Se l'angolo è maggiore di metà FOV, il giocatore è alle spalle o di lato
	if angle_diff > (FOV_ANGLE / 2.0):
		return false
		
	# 4. Muri in mezzo
	var is_visible = has_line_of_sight(player)
	if is_visible:
		# Stampa un report completo per confermare che l'angolo ora è corretto!
		print("[DEBUG] SCOPERTO! Sguardo: ", last_facing, " | Gradi di scarto: ", snapped(angle_diff, 0.1), "° (Max: 70°)")
		
	return is_visible
