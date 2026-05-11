extends Control

# ==========================================
# GESTIONE BOTTONI MENU PRINCIPALE
# ==========================================

func _on_btn_avvio_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_btn_exit_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().quit()
