extends Node
class_name MusicManager

# Qui potrai trascinare le tue due tracce di esplorazione dall'Inspector
@export var track_esplorazione_1: AudioStream
@export var track_esplorazione_2: AudioStream

var nemici_in_allerta: int = 0
var fade_tween: Tween

@onready var player_esplorazione = $PlayerEsplorazione
@onready var player_azione = $PlayerAzione

func _ready() -> void:
	# Aggiungiamo questo nodo a un gruppo per trovarlo facilmente da qualsiasi script
	add_to_group("music_manager")

	# Scegli una traccia casuale per l'esplorazione
	var tracce = [track_esplorazione_1, track_esplorazione_2]
	player_esplorazione.stream = tracce.pick_random()
	player_esplorazione.play()

# Chiamato dai nemici quando ti vedono o ti attaccano
func allerta_nemico() -> void:
	nemici_in_allerta += 1
	if nemici_in_allerta == 1:
		_cambia_musica(-80.0, 0.0) # Muta esplorazione, Alza azione

# Chiamato dai nemici quando ti perdono o muoiono
func calma_nemico() -> void:
	nemici_in_allerta = max(0, nemici_in_allerta - 1)
	if nemici_in_allerta == 0:
		_cambia_musica(0.0, -80.0) # Alza esplorazione, Muta azione

func _cambia_musica(vol_esplorazione: float, vol_azione: float) -> void:
	# Se c'è già una transizione in corso, la blocchiamo
	if fade_tween:
		fade_tween.kill()
		
	# Creiamo una dissolvenza incrociata fluida di 1.5 secondi
	fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(player_esplorazione, "volume_db", vol_esplorazione, 1.5)
	fade_tween.tween_property(player_azione, "volume_db", vol_azione, 1.5)
