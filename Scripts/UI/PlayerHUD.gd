extends CanvasLayer

@onready var health_bar: TextureProgressBar = %HealthBar
@onready var strength_bar = %StrengthBar
@onready var stealth_bar = %StealthBar
@onready var visibility_bar = %VisibilityBar
@onready var strength_level_label = %StrengthLevelLabel
@onready var stealth_level_label = %StealthLevelLabel
@onready var life_1 = %Life1
@onready var life_2 = %Life2
@onready var life_3 = %Life3

const SkillChoiceMenuScene = preload("res://Scenes/UI/skill_choise_menu.tscn")

var player_ref: Node = null

# --- VARIABILI CODA MENU ---
var menu_queue: Array[Dictionary] = []
var is_menu_active: bool = false

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("Player HUD: nessun player trovato")
		return

	# Collegamento Vita
	player.health.health_changed.connect(_on_health_changed)
	health_bar.max_value = player.health.max_health
	health_bar.value     = player.health.current_health
	
	# Collegamento XP
	if player.skills:
		player.skills.strength_xp_changed.connect(_on_strength_xp_changed)
		player.skills.stealth_xp_changed.connect(_on_stealth_xp_changed)
		
		# Ora si collegano alla logica della coda
		player.skills.strength_skill_point_earned.connect(_queue_strength_menu)
		player.skills.stealth_skill_point_earned.connect(_queue_stealth_menu)
		
		player.skills.strength_leveled_up.connect(_on_strength_level_up)
		player.skills.stealth_leveled_up.connect(_on_stealth_level_up)
		
		# Inizializza le barre al valore di partenza
		_on_strength_xp_changed(player.skills.strength_xp, player.skills.strength_xp_required)
		_on_stealth_xp_changed(player.skills.stealth_xp, player.skills.stealth_xp_required)
		
		# INIZIALIZZA I TESTI AL LIVELLO ATTUALE
		strength_level_label.text = "Liv. " + str(player.skills.strength_level)
		stealth_level_label.text = "Liv. " + str(player.skills.stealth_level)
		
		_on_strength_xp_changed(player.skills.strength_xp, player.skills.strength_xp_required)
		_on_stealth_xp_changed(player.skills.stealth_xp, player.skills.stealth_xp_required)
	
	# Collegamento Visibilità
	VisibilityManager.visibility_changed.connect(_on_visibility_changed)
	visibility_bar.value = VisibilityManager.get_visibility()

# --- FUNZIONI DI AGGIORNAMENTO UI ---

func _on_visibility_changed(level: float) -> void:
	visibility_bar.value = level

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_strength_xp_changed(current: float, maximum: float) -> void:
	strength_bar.max_value = maximum
	strength_bar.value = current

func _on_stealth_xp_changed(current: float, maximum: float) -> void:
	stealth_bar.max_value = maximum
	stealth_bar.value = current
	
# ==========================================
# GESTIONE MENU ABILITA' (SISTEMA A CODA)
# ==========================================

func _queue_strength_menu(level: int) -> void:
	_queue_menu("forza", level)

func _queue_stealth_menu(level: int) -> void:
	_queue_menu("stealth", level)

# 1. Mette il menù in fila
func _queue_menu(tree_type: String, level: int) -> void:
	menu_queue.append({"type": tree_type, "level": level})
	_check_menu_queue()

# 2. Controlla la coda
func _check_menu_queue() -> void:
	if is_menu_active:
		return
		
	# Se la coda è vuota, il gioco riparte
	if menu_queue.is_empty():
		get_tree().paused = false
		return
		
	is_menu_active = true
	get_tree().paused = true 
	
	var next = menu_queue.pop_front()
	_spawn_menu(next["type"], next["level"])

# 3. Istanzia il menù
func _spawn_menu(tree_type: String, level: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("Impossibile aprire il menù: Player non trovato!")
		return
		
	var menu_instance = SkillChoiceMenuScene.instantiate()
	add_child(menu_instance)
	
	# Si accorge di quando il menù fa queue_free()
	menu_instance.tree_exited.connect(_on_menu_closed)
	menu_instance.open_menu(tree_type, level, player.skills)

# 4. Loop della coda
func _on_menu_closed() -> void:
	is_menu_active = false
	_check_menu_queue()

# ==========================================
# FEEDBACK AUDIOVISIVO
# ==========================================

# ==========================================
# FEEDBACK AUDIOVISIVO E TESTUALE
# ==========================================

func _on_strength_level_up(new_level: int) -> void:
	strength_level_label.text = "Liv. " + str(new_level)
	_play_level_up_sfx()

func _on_stealth_level_up(new_level: int) -> void:
	stealth_level_label.text = "Liv. " + str(new_level)
	_play_level_up_sfx()

func _play_level_up_sfx() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("play_sfx"):
		player.play_sfx("SfxLevelUp")
		
func _process(_delta: float) -> void:
	# Controlla continuamente quante vite hai nel GameManager 
	# e spegne le barrette di conseguenza
	if life_1: life_1.visible = GameManager.current_lives >= 1
	if life_2: life_2.visible = GameManager.current_lives >= 2
	if life_3: life_3.visible = GameManager.current_lives >= 3
