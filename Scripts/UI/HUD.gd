extends CanvasLayer

const TorchUI = preload("res://Scenes/UI/torch_ui.tscn")

func _ready() -> void:
	UIManager.register_hud(self)

func create_torch_ui() -> Node2D:
	var torch_ui: Node2D = TorchUI.instantiate() as Node2D
	add_child(torch_ui)
	return torch_ui
