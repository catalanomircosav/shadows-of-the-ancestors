extends "res://Scripts/Enemy.gd"

var is_active: bool = false

func _ready() -> void:
	super._ready()
	
	$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED
	$CollisionShape2D.set_deferred("disabled", true)
	visible = false

func avvia_boss() -> void:
	if is_active: return
	is_active = true
	
	# 1. Suono di spawn (Assicurati che il nodo si chiami SfxSpawn in SFX/)
	play_sfx("SfxSpawn")
	
	visible = true
	
	# 2. Animazione di spawn (quella che abbiamo messo nel BossAnimPlayer)
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("spawn")
		await $AnimationPlayer.animation_finished
	
	# 3. Attiva il combattimento
	$StateMachine.process_mode = Node.PROCESS_MODE_INHERIT
	$CollisionShape2D.set_deferred("disabled", false)
