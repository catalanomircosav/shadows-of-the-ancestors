extends Node

@onready var sfx_click = $SfxClick


func play_click() -> void:
	# Aggiungiamo sempre una micro-variazione per non farlo sembrare robotico
	sfx_click.pitch_scale = randf_range(0.95, 1.05)
	sfx_click.play()
