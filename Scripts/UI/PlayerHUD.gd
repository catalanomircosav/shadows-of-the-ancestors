extends CanvasLayer

@onready var health_bar: TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/HealthBar

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("Player HUD: nessun player trovato")
		return

	player.health.health_changed.connect(_on_health_changed)
	
	health_bar.max_value = player.health.max_health
	health_bar.value	 = player.health.current_health

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
