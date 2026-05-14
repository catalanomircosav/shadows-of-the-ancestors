extends CharacterBody2D
class_name Player

@export var acceleration: float = 80.0
@export var friction: float     = 100.0
@export var max_speed: float    = 70.0
@export var run_speed: float    = 110.0
@export var damaged_mult: float = 1.0

var _is_escaping: bool = false
var move_direction: Vector2 = Vector2.ZERO
var last_facing: String = "down"
var is_ghost: bool = false

# Array per tracciare i nemici vicini per lo stealth
var enemies_in_proximity: Array = []

@onready var anim_player: AnimationPlayer  = $AnimationPlayer
@onready var sprite: AnimatedSprite2D      = $AnimatedSprite2D
@onready var sword_hitbox: Hitbox          = $SwordHitbox
@onready var health: HealthComponent       = $HealthComponent
@onready var state_machine: FSM            = $StateMachine
@onready var skills: SkillsComponent       = $SkillsComponent

var light_multiplier: float = 1.0

func _ready() -> void:
	if GameManager.has_checkpoint:
		global_position = GameManager.last_checkpoint_pos
	add_to_group("player")
	VisibilityManager.register_player(self)
	NoiseManager.register_player(self)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)
	sword_hitbox.hit_landed.connect(_on_sword_hit_landed)

func _on_damaged(kb_direction: Vector2, kb_force: float) -> void:
	state_machine.call_deferred("transition_to", &"Damaged", {
		"direction": kb_direction,
		"force":     kb_force * damaged_mult
	})
	
func _on_sword_hit_landed(target: Node) -> void:
	skills.gain_strength_xp(15.0) 
	
	# Controllo Backstab
	if "last_facing" in target:
		if target.last_facing == self.last_facing:
			# Output di debug per il Backstab (Stealth)
			skills.gain_stealth_xp(25.0)
	# ---- NUOVO: LOGICA "SETE DI SANGUE" ----
	# Se il bersaglio ha un HealthComponent, controlliamo se siamo curati alla sua morte
	if target.has_node("HealthComponent") and skills.has_skill("sete_di_sangue"):
		var enemy_health = target.get_node("HealthComponent")
		# Ci colleghiamo al segnale 'died'. 
		# IMPORTANTE: CONNECT_ONE_SHOT evita che ci curiamo più volte se colpiamo il cadavere
		if not enemy_health.died.is_connected(_on_enemy_killed_for_heal):
			enemy_health.died.connect(_on_enemy_killed_for_heal.bind(), CONNECT_ONE_SHOT)

func _on_enemy_killed_for_heal() -> void:
	# Controlla per sicurezza che il player non sia morto insieme al nemico
	if health and not health.is_dead():
		var heal_amount = 15 # Punti vita recuperati per uccisione
		health.heal(heal_amount)
		print("[COMBAT] 🩸 Sete di Sangue attivata! Il Player recupera " + str(heal_amount) + " HP.")


func _on_death() -> void:
	play_sfx("SfxDeath")
	state_machine.transition_to(&"Death")

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
	
	# =======================================================
	# CONTROLLO ABILITA' FORZA - LIVELLO 15
	# =======================================================
	# Controlliamo se sta partendo un'animazione di attacco
	if "attack" in anim_name.to_lower() and skills:
		
		# 1. RAFFICA (Velocità di attacco)
		if skills.has_skill("raffica"):
			speed_scale *= 1.40 # Aumenta la velocità del 40%
			
		# 2. RAGGIO ESTESO (Grandezza della spada)
		if skills.has_skill("raggio_esteso"):
			# Aumenta la dimensione (scala) dell'Area2D del 40%
			sword_hitbox.scale = Vector2(1.4, 1.4) 
		else:
			# Se non ha l'abilità, si assicura che la dimensione sia normale (1.0)
			sword_hitbox.scale = Vector2(1.0, 1.0)
			
		if skills.has_skill("berserker"):
			# Controlliamo se la nostra salute è sotto il 40%
			if health and health.current_health <= (health.max_health * 0.40):
				speed_scale *= 1.80 # Diventi un frullatore!
	# =======================================================
	
	anim_player.speed_scale = speed_scale
	if force_restart or anim_player.current_animation != anim_name:
		anim_player.stop()
		anim_player.play(anim_name)
		sprite.play(anim_name)

# ==============================================================================
# LOGICA STEALTH (PROSSIMITÀ)
# ==============================================================================

func _on_stealth_proximity_area_body_entered(body: Node2D) -> void:
	# Invece di is_in_group("enemy"), controlliamo se è un'istanza della tua classe EnemyBase
	if body is EnemyBase: 
		enemies_in_proximity.append(body)

func _on_stealth_proximity_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_proximity:
		enemies_in_proximity.erase(body)
		
		if state_machine and state_machine.current_state and state_machine.current_state.name == "Crouch":
			var enemy_state_machine = body.get_node_or_null("StateMachine")
			
			if enemy_state_machine and enemy_state_machine.current_state:
				var current_enemy_state = enemy_state_machine.current_state.name
				
				if current_enemy_state != "Chase" and current_enemy_state != "Attack":
					skills.gain_stealth_xp(20.0)
					
# ==============================================================================
# ABILITA' STEALTH
# ==============================================================================

func trigger_escape_route() -> void:
	# Controlla se ha la skill e se non sta già scappando
	if skills and skills.has_skill("via_di_fuga") and not _is_escaping:
		_is_escaping = true
		print("[STEALTH] 🚨 SCOPERTO! Via di Fuga attiva: Velocità aumentata per 3 sec!")
		
		# Salviamo le velocità originali
		var original_max = max_speed
		var original_run = run_speed
		
		# Aumentiamo la velocità del 60%
		max_speed *= 1.6
		run_speed *= 1.6
		
		# Aspettiamo 3 secondi
		await get_tree().create_timer(3.0).timeout
		
		# Ripristiniamo la situazione normale
		max_speed = original_max
		run_speed = original_run
		_is_escaping = false
				
func activate_ghost_mode() -> void:
	if skills and skills.has_skill("fantasma") and not is_ghost:
		is_ghost = true
		print("[STEALTH] 👻 FANTASMA! Sei invisibile per 4 secondi!")
		
		# Effetto visivo: rendiamo il player semi-trasparente!
		sprite.modulate.a = 0.4
		
		await get_tree().create_timer(4.0).timeout
		
		# Fine invisibilità
		sprite.modulate.a = 1.0
		is_ghost = false
		print("[STEALTH] 👁️ Tornerai ad essere visibile.")
		
# ==============================================================================
# GESTIONE AUDIO
# ==============================================================================

func play_sfx(sound_name: String) -> void:
	# Cerca il nodo audio dentro la nostra "cartellina" SFX
	var audio_node = get_node_or_null("SFX/" + sound_name)
	
	if audio_node and audio_node is AudioStreamPlayer2D:
		# Applica in automatico la variazione casuale per non annoiare l'orecchio
		audio_node.pitch_scale = randf_range(0.85, 1.15)
		audio_node.play()
	else:
		push_warning("SFX non trovato: " + sound_name)
		

func _on_level_up(_new_level: int) -> void:
	# 1. Peschiamo il player dal gioco
	var player = get_tree().get_first_node_in_group("player")
	
	# 2. Se il player esiste e ha la funzione, gli diciamo di far partire il SUO suono!
	if player and player.has_method("play_sfx"):
		player.play_sfx("SfxLevelUp")
