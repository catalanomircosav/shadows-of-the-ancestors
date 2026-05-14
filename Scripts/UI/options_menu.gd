extends Control

@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SFXSlider
@onready var fullscreen_check = %FullScreen

var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

# 1. Creiamo le "scatole della memoria" per quando annulliamo
var original_music_db: float
var original_sfx_db: float
var original_fullscreen: bool

func _ready() -> void:
	# MEMORIZZIAMO I VALORI ATTUALI PRIMA DI TOCCARLI
	original_music_db = AudioServer.get_bus_volume_db(music_bus)
	original_sfx_db = AudioServer.get_bus_volume_db(sfx_bus)
	original_fullscreen = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# IMPOSTIAMO LA GRAFICA (slider e spunta) AI VALORI REALI
	music_slider.value = db_to_linear(original_music_db)
	sfx_slider.value = db_to_linear(original_sfx_db)
	fullscreen_check.button_pressed = original_fullscreen

# ==========================================
# MODIFICHE IN TEMPO REALE (Per dare feedback)
# ==========================================

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	# Suonino di prova!
	if UIAudioManager.has_method("play_click"):
		UIAudioManager.play_click()

func _on_full_screen_toggled(toggled_on: bool) -> void:
	print("Hai cliccato la spunta! Valore: ", toggled_on)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if UIAudioManager.has_method("play_click"):
		UIAudioManager.play_click()

# ==========================================
# I DUE BOTTONI FINALI
# ==========================================

# BOTTONE INDIETRO / ANNULLA
func _on_btn_cancel_pressed() -> void:
	if UIAudioManager.has_method("play_click"):
		UIAudioManager.play_click()
		
	# OPS! HA CAMBIATO IDEA! Ripristiniamo i valori che ci eravamo segnati all'inizio:
	AudioServer.set_bus_volume_db(music_bus, original_music_db)
	AudioServer.set_bus_volume_db(sfx_bus, original_sfx_db)
	
	if original_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	queue_free() # Chiude il menù

# BOTTONE SALVA / CONFERMA
func _on_btn_save_pressed() -> void:
	if UIAudioManager.has_method("play_click"):
		UIAudioManager.play_click()
		
	# Qui non dobbiamo modificare l'AudioServer, perché è già stato modificato dagli slider.
	# Dobbiamo però SALVARE queste impostazioni nel computer del giocatore!
	_salva_impostazioni_su_file()
	
	queue_free() # Chiude il menù

# ==========================================
# SALVATAGGIO DEFINITIVO SU FILE (Extra Pro)
# ==========================================

func _salva_impostazioni_su_file() -> void:
	# Godot ha un oggetto comodissimo per salvare le impostazioni
	var config = ConfigFile.new()
	
	# Scriviamo i valori attuali
	config.set_value("Audio", "music_volume", music_slider.value)
	config.set_value("Audio", "sfx_volume", sfx_slider.value)
	config.set_value("Video", "fullscreen", fullscreen_check.button_pressed)
	
	# Salva tutto in un file nascosto nella cartella di gioco dell'utente!
	config.save("user://settings.cfg")
	print("Impostazioni Salvate con successo!")
