extends State
class_name DeathState

var _player: Player

func _setup() -> void:
	_player = state_machine.get_parent() as Player

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player.velocity = Vector2.ZERO
	_player.set_deferred("collision_layer", 0)
	_player.set_deferred("collision_mask", 0)
	
	if _player.has_node("Area2D/HurtBox"):
		_player.get_node("Area2D/HurtBox").set_deferred("disabled", true)
		
	_player.play_animation("death_" + _player.last_facing, 1.0, true)
	_player.anim_player.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)

func exit(_next_state: StringName = &"") -> void:
	pass
	
func _on_death_animation_finished(_anim_name: String) -> void:
	await get_tree().create_timer(2.5, false).timeout
	
	GameManager.current_lives -= 1
	
	if GameManager.current_lives > 0:
		get_tree().reload_current_scene()
	else:
		GameManager.current_lives = GameManager.max_lives
		GameManager.has_checkpoint = false
		get_tree().change_scene_to_file("res://Scenes/UI/death_menu.tscn")
