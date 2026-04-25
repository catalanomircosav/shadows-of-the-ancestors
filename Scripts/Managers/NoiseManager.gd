extends Node

var _player: Player = null
var noise_radius: float = 0.0
var noise_position: Vector2 = Vector2.ZERO

const IMPULSE := {
	"CROUCH": 20.0,
	"WALK": 60.0,
	"RUN": 140.0,
}
const DECAY_SPEED := {
	"CROUCH": 8.0,
	"WALK": 4.0,
	"RUN": 2.0,
}
const STEP_INTERVAL := {
	"CROUCH": 0.6,
	"WALK": 0.4,
	"RUN": 0.25,
}

var _current_decay: float = 4.0

func register_player(player: Player) -> void:
	_player = player

func emit_step(state: String) -> void:
	if not IMPULSE.has(state):
		return
	var impulse = IMPULSE[state]
	if _player:
		emit_noise(_player.global_position, impulse, DECAY_SPEED[state])

func emit_noise(position: Vector2, impulse: float, decay: float = 3.0) -> void:
	if impulse > noise_radius:
		noise_radius = impulse
		_current_decay = decay
		noise_position = position

func get_noise_radius() -> float:
	return noise_radius

func get_noise_position() -> Vector2:
	return noise_position

func _process(delta: float) -> void:
	if noise_radius > 0.0:
		noise_radius -= noise_radius * _current_decay * delta
		if noise_radius < 0.5:
			noise_radius = 0.0
			noise_position = Vector2.ZERO
	
	# --- DEBUG -----------------------------
	#if Engine.get_process_frames() % 30 == 0:
		#print("Noise radius: %.1f | pos: %s" % [noise_radius, noise_position])
