extends Node
# ==============================================================================
# SCRIPT: VisibilityManager.gd
# DESCRIZIONE: Calcola dinamicamente la visibilità del giocatore in base alla
# sua distanza dalle torce accese presenti nel livello.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _torches: Array[Node] = []
var _player: Player = null
var _visibility: float = 0.0
signal visibility_changed(level: float)
var _last_emitted_visibility: float = -1.0


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================
func _process(_delta: float) -> void:
	# Interrompe il calcolo se il giocatore non esiste o non ci sono torce
	if _player == null or _torches.is_empty():
		return
	
	var total_visibility: float = 0.0
	
	# Calcola il contributo alla visibilità di ogni singola torcia
	for torch in _torches:
		# Salta le torce rimosse dalla memoria o spente
		if not is_instance_valid(torch):
			continue
		if not torch.is_lit:
			continue
		
		# Calcola raggio, distanza e contributo della singola torcia
		var radius: float = torch.light.texture_scale * 64.0 / 2.0
		var distance: float = _player.global_position.distance_to(torch.global_position)
		
		var contribution: float = clamp(1.0 - (distance / radius), 0.0, 1.0)
		contribution *= torch.current_base_energy
		total_visibility += contribution
	
	# Applica i moltiplicatori del giocatore e blocca il valore massimo a 1.0
	total_visibility *= _player.light_multiplier
	total_visibility = clamp(total_visibility, 0.0, 1.0)
	
	_visibility = total_visibility
	
	# Emette il segnale solo se la visibilità è cambiata dell'1% o più
	if abs(_visibility - _last_emitted_visibility) >= 0.01:
		visibility_changed.emit(_visibility)
		_last_emitted_visibility = _visibility


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Registra il riferimento al giocatore per calcolarne la posizione.
func register_player(player: Node) -> void:
	_player = player

## Aggiunge una nuova torcia alla lista di quelle tracciate.
func register_torch(torch: Node) -> void:
	if not _torches.has(torch):
		_torches.append(torch)

## Rimuove una torcia dalla lista di quelle tracciate.
func unregister_torch(torch: Node) -> void:
	_torches.erase(torch)

## Restituisce l'attuale livello di visibilità del giocatore (da 0.0 a 1.0).
func get_visibility() -> float:
	return _visibility
