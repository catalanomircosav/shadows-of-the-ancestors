extends State
class_name EnemyInvestigateState
# ==============================================================================
# SCRIPT: enemy_investigate.gd
# ==============================================================================

const INVESTIGATE_SPEED: float = 40.0
const VISION_RANGE: float = 200.0      
const CLOSE_VISION_RANGE: float = 80.0 

var _enemy: EnemyBase
var _player: Player
var _nav_agent: NavigationAgent2D
var _direction_anim: Vector2 = Vector2.ZERO
var _investigate_timer: float = 0.0

var _is_reacting: bool = false
var _reaction_timer: float = 0.0

func _setup() -> void:
	_enemy = state_machine.get_parent() as EnemyBase
	_nav_agent = _enemy.get_node("NavigationAgent2D")

func enter(_previous_state: StringName = &"", _data: Dictionary = {}) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	_investigate_timer = 5.0
	_nav_agent.target_position = _enemy.noise_target_position
	
	# FIX: Non calcoliamo la nuova direzione subito!
	# Rimane girato nella direzione in cui stava già guardando e si ferma in allerta.
	_enemy.play_animation("idle_" + _enemy.last_facing)
	
	_is_reacting = true
	_reaction_timer = 0.6 # Questa è la tua finestra per il backstab!

func physics_update(delta: float) -> void:
	
	# 1. VISIONE DINAMICA E CONO VISIVO
	if is_instance_valid(_player):
		var player_vis: float = VisibilityManager.get_visibility()
		var dynamic_vision_range: float = CLOSE_VISION_RANGE + ((VISION_RANGE - CLOSE_VISION_RANGE) * player_vis)
		
		# Deleghiamo il controllo visivo (Crouch, FOV, Muri) al nemico
		if _enemy.can_see_player(_player, dynamic_vision_range):
			_enemy.velocity = Vector2.ZERO
			state_machine.transition_to(&"Chase")
			return
				
	# 2. FASE DI REAZIONE (Ora si gira SOLO QUANDO il timer scade)
	if _is_reacting:
		_reaction_timer -= delta
		if _reaction_timer <= 0.0:
			_is_reacting = false
			# Il timer è scaduto: ORA calcola la direzione, si gira verso il rumore e inizia a correre
			_update_movement_and_anim(false)
		return 
	
	# 3. LOGICA DI INVESTIGAZIONE (Movimento effettivo)
	_investigate_timer -= delta
	
	if _nav_agent.is_navigation_finished() or _investigate_timer <= 0.0:
		_enemy.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return
		
	var next_path_position: Vector2 = _nav_agent.get_next_path_position()
	var real_direction: Vector2 = _enemy.global_position.direction_to(next_path_position)
	
	_enemy.velocity = real_direction * INVESTIGATE_SPEED
	_enemy.move_and_slide()
	
	_update_movement_and_anim(false)
	
	if _enemy.is_on_wall():
		_investigate_timer -= delta * 1.5

func _update_movement_and_anim(is_just_turning: bool = false) -> void:
	# 1. Determiniamo la direzione "reale"
	var real_dir: Vector2 = _enemy.velocity.normalized()
	
	# Se è fermo (es. all'inizio, quando sente il rumore ma non è ancora partito)
	# la direzione "reale" è verso il bersaglio del rumore.
	if real_dir.length_squared() < 0.01:
		real_dir = _enemy.global_position.direction_to(_enemy.noise_target_position)
		
	# 2. Deleghiamo l'aggiornamento della stringa (last_facing) al nemico
	_enemy.update_facing_direction(real_dir)
	
	# 3. Riproduciamo l'animazione corretta usando last_facing
	if is_just_turning:
		_enemy.play_animation("idle_" + _enemy.last_facing)
	else:
		_enemy.play_animation("run_" + _enemy.last_facing)
