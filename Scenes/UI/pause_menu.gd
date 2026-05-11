extends CanvasLayer

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


func _on_btn_exit_pressed() -> void:
	UIAudioManager.play_click()
	get_tree().paused = false
	
	var errore = get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
