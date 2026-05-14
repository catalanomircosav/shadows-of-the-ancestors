extends CanvasLayer
# ==============================================================================
# SCRIPT: death_menu.gd
# ==============================================================================

func _ready() -> void:
	pass

func _on_btn_restart_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()


func _on_btn_back_to_menu_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	queue_free()
