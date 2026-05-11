extends Control

# 1. Carichiamo la scena delle opzioni in memoria (CONTROLLA IL PERCORSO!)
const OptionsMenuScene = preload("res://Scenes/UI/options_menu.tscn") 

# ==========================================
# GESTIONE BOTTONI MENU PRINCIPALE
# ==========================================

func _on_btn_avvio_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

# 2. La nuova funzione per aprire le Opzioni
func _on_btn_options_pressed() -> void:
	UIAudioManager.play_click()
	
	# Creiamo il menù opzioni e lo "appiccichiamo" sopra al menù principale
	var options_instance = OptionsMenuScene.instantiate()
	add_child(options_instance)

func _on_btn_exit_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().quit()
