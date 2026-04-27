extends Node
# ==============================================================================
# SCRIPT: UIManager.gd
# DESCRIZIONE: Gestisce i riferimenti all'interfaccia utente (HUD) globale, 
# permettendo ad altri sistemi di accedervi da un punto centralizzato.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _hud: CanvasLayer = null


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Registra il riferimento al nodo CanvasLayer che funge da HUD principale.
func register_hud(hud: CanvasLayer) -> void:
	_hud = hud

## Restituisce il riferimento all'HUD attualmente registrato.
func get_hud() -> CanvasLayer:
	return _hud
