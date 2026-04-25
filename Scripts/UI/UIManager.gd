extends Node

var _hud: CanvasLayer = null

func register_hud(hud: CanvasLayer) -> void:
	_hud = hud

func get_hud() -> CanvasLayer:
	return _hud
