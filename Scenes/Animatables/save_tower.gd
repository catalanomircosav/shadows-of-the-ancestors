extends Node2D # o StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func accendi(suona: bool = true) -> void:
	anim.play("default")
	
	if suona and audio_player.stream != null:
		audio_player.play()
