extends Node2D

const MAX_WIDTH = 96.0

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/Label


var _tween: Tween


func _ready():
	panel.hide()


func show_text(text: String, duration := 3.0):
	if _tween:
		_tween.kill()

	# Breite an den Text anpassen, aber höchstens MAX_WIDTH
	var font = label.get_theme_font("font")
	var font_size = label.get_theme_font_size("font_size")
	var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	label.custom_minimum_size.x = minf(text_width + 2.0, MAX_WIDTH)

	label.text = text
	label.visible_ratio = 0.0
	panel.modulate.a = 0.0  # unsichtbar, bis die Größe berechnet ist
	panel.show()
	panel.reset_size()
	await get_tree().process_frame

	# Unterkante mittig über dem Ursprung
	panel.position = Vector2(-panel.size.x / 2.0, -panel.size.y)
	panel.modulate.a = 1.0

	_tween = create_tween()
	_tween.tween_property(label, "visible_ratio", 1.0, maxf(0.2, text.length() * 0.03))
	await get_tree().create_timer(duration).timeout


func hide_bubble():
	panel.hide()
