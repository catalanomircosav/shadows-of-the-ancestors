## player.gd
## Nodo principale del giocatore.
## Contiene solo dati e helper condivisi tra gli stati.
extends CharacterBody2D
class_name Player

@export var acceleration: float = 80.0
@export var friction: float     = 100.0
@export var max_speed: float    = 190.0
@export var run_speed: float    = 304.0   # max_speed * 1.6

## Direzione corrente dell'input (aggiornata dagli stati).
var move_direction: Vector2 = Vector2.ZERO

## Ultima direzione affrontata; usata per scegliere l'animazione.
var last_facing: String = "down"

# Riferimenti cachati — evitano get_node() ripetuti negli stati.
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D     = $AnimatedSprite2D

# ── helpers ────────────────────────────────────────────────────────────────
var light_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("player")
	VisibilityManager.register_player(self)
	NoiseManager.register_player(self)
## Aggiorna last_facing in base a una direzione normalizzata.
## Priorità: asse orizzontale > asse verticale.
func update_facing_direction(direction: Vector2) -> void:
	if direction.x > 0.0:
		last_facing = "right"
	elif direction.x < 0.0:
		last_facing = "left"
	elif direction.y > 0.0:
		last_facing = "down"
	elif direction.y < 0.0:
		last_facing = "up"


## Riproduce un'animazione.
## Il parametro force_restart forza il play anche se è già l'animazione corrente
## — necessario per stati che devono sempre ripartire dall'inizio (es. idle dopo attack).
func play_animation(anim_name: String, speed_scale: float = 1.0, force_restart: bool = false) -> void:
	anim_player.speed_scale = speed_scale
	if force_restart or anim_player.current_animation != anim_name:
		anim_player.stop() # Ferma la timeline per sicurezza
		anim_player.play(anim_name)
		sprite.play(anim_name)
