extends Area2D
class_name CheckpointStatue

const E_SHOW_DURATION: float = 0.3
const E_HIDE_DURATION: float = 0.2
const E_OFFSET: Vector2 = Vector2(0, -40) 

# Lista delle torri da accendere (assegnali dall'Ispettore nel livello)
@export var torri_collegate: Array[Node2D] 
# Font personalizzato e grandezza per la scritta
@export var font_personalizzato: Font
@export var dimensione_testo: int = 16

var is_already_lit: bool = false
var _player_ref: Node2D = null
var _ui_node: Node2D = null
var _e_tween: Tween

func _ready() -> void:
	_setup_ui.call_deferred()
	
	if GameManager.has_checkpoint and GameManager.last_checkpoint_pos == global_position:
		is_already_lit = true
		for torre in torri_collegate:
			if torre != null and torre.has_method("accendi"):
				# call_deferred aspetta che la torre sia pronta.
				# Passiamo "false" così il suono non parte al respawn.
				torre.call_deferred("accendi", false)

func _setup_ui() -> void:
	while UIManager.get_hud() == null:
		await get_tree().process_frame
	var hud := UIManager.get_hud()
	_ui_node = hud.create_torch_ui() # Usa l'UI della torcia (tasto E)
	_ui_node.visible = false
	_ui_node.scale = Vector2.ZERO

func _process(_delta: float) -> void:
	# Mantiene il tasto "E" ancorato sopra la statua
	if _ui_node:
		_ui_node.global_position = get_canvas_transform() * global_position + E_OFFSET

func _unhandled_input(event: InputEvent) -> void:
	if _player_ref and event.is_action_pressed("interact"):
		_attiva_falo()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_ref = body
		_animate_e(true)

func _on_body_exited(body: Node2D) -> void:
	if body == _player_ref:
		_player_ref = null
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
			if not _player_ref:
				_ui_node.visible = false
		, CONNECT_ONE_SHOT)

func _attiva_falo() -> void:
	if is_already_lit:
		return

	GameManager.last_checkpoint_pos = global_position
	GameManager.has_checkpoint = true
	
	GameManager.current_lives = GameManager.max_lives

	var health_comp = _player_ref.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.heal(health_comp.max_health)
	
	is_already_lit = true
	_animate_e(false)
	
	print("Vite ricaricate! Checkpoint attivo.")
	_mostra_scritta_salvataggio()
	
	for torre in torri_collegate:
		if torre != null and torre.has_method("accendi"):
			torre.accendi(true)
		
		
func _mostra_scritta_salvataggio() -> void:
	var label = Label.new()
	label.text = "Salvataggio effettuato"
	
	if font_personalizzato:
		label.add_theme_font_override("font", font_personalizzato)
	label.add_theme_font_size_override("font_size", dimensione_testo)
	
	# TRUCCO PER CENTRARE: Diamo una larghezza fissa (es. 400 pixel) alla Label
	label.custom_minimum_size = Vector2(400, 0)
	# Diciamo al testo di allinearsi al centro di questi 400 pixel
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_outline_size", 3)
	
	# Ora la centratura è perfetta. 
	# Sottraiamo esattamente metà della larghezza fissa (-200 sulla X).
	# Modifica il -80 sulla Y se vuoi che la scritta parta più in alto o più in basso.
	label.global_position = global_position + Vector2(-200, -80)
	label.z_index = 50 
	
	get_tree().current_scene.add_child(label)
	
	var tween = create_tween().set_parallel(true)
	
	# Animazione: sale di altri 50 pixel verso l'alto
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -50), 1.5)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
	tween.tween_property(label, "modulate:a", 0.0, 1.5)\
		.set_trans(Tween.TRANS_LINEAR)
		
	tween.chain().tween_callback(label.queue_free)
