extends Node2D

@onready var light: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const MAX_ENERGY: float = 1.2
const FLICKER_SPEED: float = 50.0
const FLICKER_AMOUNT: float = 0.2
const NOISE_FREQUENCY: float = 0.1
const LIGHT_ON_DURATION: float = 0.3
const LIGHT_OFF_DURATION: float = 0.6
const E_SHOW_DURATION: float = 0.3
const E_HIDE_DURATION: float = 0.2
const E_OFFSET: Vector2 = Vector2(1, -15)

var is_lit: bool = true
var player_in_range: bool = false
var current_base_energy: float = MAX_ENERGY
var _ui_node: Node2D = null

var _light_tween: Tween
var _e_tween: Tween
var _noise := FastNoiseLite.new()
var _time_passed: float = 0.0

func _ready() -> void:
	add_to_group("torches")
	sprite.play("default")
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = NOISE_FREQUENCY
	_setup_ui.call_deferred()
	
	VisibilityManager.register_torch(self)

func _setup_ui() -> void:
	while UIManager.get_hud() == null:
		await get_tree().process_frame
	var hud := UIManager.get_hud()
	_ui_node = hud.create_torch_ui()
	_ui_node.visible = false
	_ui_node.scale = Vector2.ZERO

func _process(delta: float) -> void:
	if current_base_energy > 0.0:
		_time_passed += delta * FLICKER_SPEED
		light.energy = current_base_energy + _noise.get_noise_1d(_time_passed) * FLICKER_AMOUNT
	else:
		light.energy = 0.0

	if _ui_node:
		_ui_node.global_position = get_canvas_transform() * global_position + E_OFFSET

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		toggle_torch()

func toggle_torch() -> void:
	is_lit = !is_lit
	sprite.play("default" if is_lit else "unlit")

	if _light_tween:
		_light_tween.kill()
	_light_tween = create_tween().set_trans(Tween.TRANS_SINE)

	var target_energy := MAX_ENERGY if is_lit else 0.0
	var duration := LIGHT_ON_DURATION if is_lit else LIGHT_OFF_DURATION
	_light_tween.tween_property(self, "current_base_energy", target_energy, duration)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_animate_e(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		_animate_e(false)

func _animate_e(visible_state: bool) -> void:
	if _ui_node == null:
		return
	if _e_tween:
		_e_tween.kill()
	_e_tween = create_tween()

	if visible_state:
		_ui_node.visible = true
		_e_tween.tween_property(_ui_node, "scale", Vector2.ONE, E_SHOW_DURATION)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_e_tween.tween_property(_ui_node, "scale", Vector2.ZERO, E_HIDE_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		_e_tween.finished.connect(func():
			if not player_in_range:
				_ui_node.visible = false
		, CONNECT_ONE_SHOT)

func _exit_tree() -> void:
	if _ui_node:
		_ui_node.queue_free()
		
	VisibilityManager.unregister_torch(self)
