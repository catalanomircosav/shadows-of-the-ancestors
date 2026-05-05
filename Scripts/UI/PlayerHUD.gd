extends CanvasLayer

@onready var health_bar: TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/HealthBar

# 1. Aggiungiamo i riferimenti alle nuove barre
@onready var strength_bar = $MarginContainer/VBoxContainer/StrengthBar
@onready var stealth_bar = $MarginContainer/VBoxContainer/StealthBar

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
