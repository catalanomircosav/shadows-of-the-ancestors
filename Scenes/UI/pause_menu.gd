extends CanvasLayer

# 1. Carichiamo la scena delle opzioni in memoria
const OptionsMenuScene = preload("res://Scenes/UI/options_menu.tscn")

func _ready() -> void:
	hide()

# Ascolta gli input della tastiera in ogni momento
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var is_paused = get_tree().paused
	
	get_tree().paused = !is_paused
	visible = !is_paused
	
func _on_btn_play_pressed() -> void:
	UIAudioManager.play_click()
	toggle_pause()

# ==========================================
# NUOVI TASTI OPZIONI ED EXIT
# ==========================================

func _on_btn_option_pressed() -> void:
	UIAudioManager.play_click()
	
	# Crea l'istanza delle opzioni e la sovrappone al menù di pausa
	var options_instance = OptionsMenuScene.instantiate()
	add_child(options_instance)

func _on_btn_exit_pressed() -> void:
	UIAudioManager.play_click()
	
	# 1. Togliamo la pausa (FONDAMENTALE prima di cambiare scena!)
	get_tree().paused = false
	
	# 2. Torniamo al menù principale
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn") # <-- CONTROLLA IL PERCORSO
