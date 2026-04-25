extends Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var radius = NoiseManager.noise_radius
	if radius <= 0.0:
		return
	
	# Cerchio pieno semitrasparente
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.0, 0.08))
	# Bordo
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1.0, 0.3, 0.0, 0.6), 1.5)
