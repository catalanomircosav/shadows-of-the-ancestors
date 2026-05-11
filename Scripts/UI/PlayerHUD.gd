extends CanvasLayer

@onready var health_bar: TextureProgressBar = %HealthBar

# 1. Aggiungiamo i riferimenti alle nuove barre
@onready var strength_bar = %StrengthBar
@onready var stealth_bar = %StealthBar

# Precarica la scena del menù
const SkillChoiceMenuScene = preload("res://Scenes/UI/skill_choise_menu.tscn")

# Mi salvo un riferimento al player per usarlo dopo
var player_ref: Node = null

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("Player HUD: nessun player trovato")
		return

	# Collegamento Vita
	player.health.health_changed.connect(_on_health_changed)
	health_bar.max_value = player.health.max_health
	health_bar.value     = player.health.current_health
	
	# 2. Collegamento XP (Assumendo che nel Player tu abbia chiamato il nodo "skills")
	if player.skills:
		player.skills.strength_xp_changed.connect(_on_strength_xp_changed)
		player.skills.stealth_xp_changed.connect(_on_stealth_xp_changed)
		player.skills.strength_skill_point_earned.connect(_on_strength_point)
		player.skills.stealth_skill_point_earned.connect(_on_stealth_point)
		
		player.skills.strength_leveled_up.connect(_on_level_up)
		player.skills.stealth_leveled_up.connect(_on_level_up)
		
		# Inizializza le barre al valore di partenza
		_on_strength_xp_changed(player.skills.strength_xp, player.skills.strength_xp_required)
		_on_stealth_xp_changed(player.skills.stealth_xp, player.skills.stealth_xp_required)

# --- FUNZIONI DI AGGIORNAMENTO UI ---

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
# GESTIONE MENU ABILITA'
# ==========================================

func _on_strength_point(level: int) -> void:
	_spawn_menu("forza", level)

func _on_stealth_point(level: int) -> void:
	_spawn_menu("stealth", level)

func _spawn_menu(tree_type: String, level: int) -> void:
	# Peschiamo il player fresco fresco direttamente dalla scena
	var player = get_tree().get_first_node_in_group("player")
	
	# Controllo di sicurezza: se per qualche motivo il player non c'è, fermiamo tutto
	if player == null:
		push_error("Impossibile aprire il menù: Player non trovato!")
		return
		
	# 1. Crea un'istanza della scena del menù
	var menu_instance = SkillChoiceMenuScene.instantiate()
	
	# 2. Aggiungilo all'HUD (lo mette visivamente sopra tutto il resto)
	add_child(menu_instance)
	
	# 3. Avvia la logica del menù passando le variabili giuste dal player appena trovato
	menu_instance.open_menu(tree_type, level, player.skills)
	
	# ==========================================
# FEEDBACK AUDIOVISIVO
# ==========================================

# ==========================================
# FEEDBACK AUDIOVISIVO
# ==========================================

func _on_level_up(new_level: int) -> void:
	print("--- TEST LEVEL UP ---")
	print("1. HUD: Segnale ricevuto! Nuovo livello: ", new_level)
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("2. HUD: Player trovato nella scena!")
		if player.has_method("play_sfx"):
			print("3. HUD: Il Player ha la funzione play_sfx. La chiamo ora!")
			player.play_sfx("SfxLevelUp")
		else:
			print("ERRORE: Il Player non ha la funzione 'play_sfx'!")
	else:
		print("ERRORE: Nessun player trovato nel gruppo 'player'!")
