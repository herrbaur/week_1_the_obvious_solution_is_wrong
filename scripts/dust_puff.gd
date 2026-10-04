extends CPUParticles2D
# Kleine Staubwolke: erzeugen, hinzufügen, fertig. Löscht sich selbst.


func _ready():
	one_shot = true
	amount = 6
	lifetime = 0.35
	explosiveness = 0.9
	z_index = 4  # hinter dem Spieler (z_index 5), vor den Tiles

	emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emission_rect_extents = Vector2(4, 1)  # breit wie die Füße

	direction = Vector2(0, -1)
	spread = 70.0
	initial_velocity_min = 15.0
	initial_velocity_max = 35.0
	gravity = Vector2.ZERO
	damping_min = 30.0
	damping_max = 50.0

	scale_amount_min = 2.0
	scale_amount_max = 3.0  # 2-3 Pixel große Quadrate passen zu Pixel-Art

	var ramp = Gradient.new()
	ramp.set_color(0, Color(0.9, 0.9, 0.95, 0.9))
	ramp.set_color(1, Color(0.9, 0.9, 0.95, 0.0))  # blendet aus
	color_ramp = ramp

	finished.connect(queue_free)
	emitting = true
