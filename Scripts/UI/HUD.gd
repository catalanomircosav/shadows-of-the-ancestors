extends CanvasLayer
# ==============================================================================
# SCRIPT: HUD.gd / UI.gd
# DESCRIZIONE: Gestisce il CanvasLayer principale dell'interfaccia utente.
# Si registra autonomamente nel manager globale e permette l'istanziamento
# dinamico di elementi UI, come gli indicatori delle torce.
# ==============================================================================

# ------------------------------------------------------------------------------
# COSTANTI
# ------------------------------------------------------------------------------
# Carica in memoria la scena dell'interfaccia della torcia al momento del parsing
const TorchUI: PackedScene = preload("res://Scenes/UI/TorchUI.tscn")


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	# Si auto-registra nell'UIManager globale non appena entra in scena,
	# rendendosi accessibile ad altri sistemi di gioco
	UIManager.register_hud(self)


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Istanzia un nuovo elemento UI per una torcia, lo aggiunge come figlio 
## al CanvasLayer e ne restituisce il riferimento.
func create_torch_ui() -> Node2D:
	# Crea l'istanza e ne forza il cast a Node2D
	var torch_ui: Node2D = TorchUI.instantiate() as Node2D
	
	# Aggiunge l'elemento all'albero della scena in modo che sia visibile
	add_child(torch_ui)
	
	# Restituisce il nodo per permettere al chiamante di configurarlo
	return torch_ui
