extends Node
# ==============================================================================
# SCRIPT: NoiseManager.gd
# DESCRIZIONE: Gestisce l'emissione e il decadimento del rumore generato dal
# giocatore o da altre entità nel mondo di gioco.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
const IMPULSE: Dictionary = {
	"CROUCH": 4.0,
	"WALK": 60.0,
	"RUN": 140.0,
}

const DECAY_SPEED: Dictionary = {
	"CROUCH": 8.0,
	"WALK": 4.0,
	"RUN": 2.0,
}

const STEP_INTERVAL: Dictionary = {
	"CROUCH": 0.6,
	"WALK": 0.4,
	"RUN": 0.25,
}

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _player: Player = null
var _current_decay: float = 4.0

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
var noise_radius: float = 0.0
var noise_position: Vector2 = Vector2.ZERO


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================
func _process(delta: float) -> void:
	# Applica il decadimento al raggio del rumore nel tempo
	if noise_radius > 0.0:
		# Il rumore decade proporzionalmente alla sua grandezza e al decay attuale
		noise_radius -= noise_radius * _current_decay * delta
		
		# Se il rumore diventa trascurabile, lo azzera per evitare micro-valori
		if noise_radius < 0.5:
			noise_radius = 0.0
			noise_position = Vector2.ZERO
	
	# --- DEBUG -----------------------------
	#if Engine.get_process_frames() % 30 == 0:
		# print("Noise radius: %.1f | pos: %s" % [noise_radius, noise_position])


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Registra il riferimento al nodo Player da tracciare per il rumore dei passi.
func register_player(player: Player) -> void:
	_player = player

## Emette un rumore basato su uno stato di movimento specifico (es. "RUN").
func emit_step(state: String) -> void:
	# Ignora se lo stato non è mappato nel dizionario
	if not IMPULSE.has(state):
		return
		
	var impulse: float = IMPULSE[state]
	
	# Emette il rumore solo se il giocatore è stato precedentemente registrato
	if _player != null:
		emit_noise(_player.global_position, impulse, DECAY_SPEED[state])

## Registra un nuovo evento di rumore nel mondo, aggiornandone i parametri.
func emit_noise(position: Vector2, impulse: float, decay: float = 3.0) -> void:
	# Sovrascrive il rumore attuale solo se il nuovo impulso è più forte
	if impulse > noise_radius:
		noise_radius = impulse
		_current_decay = decay
		noise_position = position

## Restituisce il raggio attuale del rumore.
func get_noise_radius() -> float:
	return noise_radius

## Restituisce la posizione da cui ha avuto origine il rumore attuale.
func get_noise_position() -> Vector2:
	return noise_position
