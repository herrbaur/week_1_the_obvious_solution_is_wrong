extends CanvasLayer

@onready var show_delay = $ShowDelay
@onready var result_label = $CenterContainer/PanelContainer/VBoxContainer/ResultLabel
@onready var grid = $CenterContainer/PanelContainer/VBoxContainer/EntriesGrid
@onready var play_again_button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/PlayAgainButton
@onready var quit_button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/QuitButton

var _time := 0.0
var _rank := -1


func _ready():
	hide()
	GameStats.run_finished.connect(_on_run_finished)
	show_delay.timeout.connect(_show_screen)
	play_again_button.pressed.connect(_on_play_again)
	quit_button.pressed.connect(_on_quit)


func _exit_tree():
	GameStats.run_finished.disconnect(_on_run_finished)


func _on_run_finished(time: float, rank: int):
	_time = time
	_rank = rank
	show_delay.start()


func _show_screen():
	_fill()
	show()
	get_tree().paused = true


func _fill():
	for child in grid.get_children():
		child.queue_free()

	var time_text = GameStats.format_time(_time)
	if _rank >= 0:
		result_label.text = "Deine Zeit: %s  -  Platz %d" % [time_text, _rank + 1]
	else:
		result_label.text = "Deine Zeit: %s  -  nicht in den Top 10" % time_text

	_add_row("#", "Zeit", "Datum", Color(0.7, 0.7, 0.7))
	for i in GameStats.MAX_ENTRIES:
		if i < GameStats.highscores.size():
			var entry = GameStats.highscores[i]
			var color = Color(1.0, 0.85, 0.2) if i == _rank else Color.WHITE
			_add_row(str(i + 1), GameStats.format_time(entry["time"]), entry["date"], color)
		else:
			_add_row(str(i + 1), "--:--.--", "", Color(0.5, 0.5, 0.5))


func _add_row(a: String, b: String, c: String, color: Color):
	for text in [a, b, c]:
		var label = Label.new()
		label.text = text
		label.add_theme_color_override("font_color", color)
		grid.add_child(label)


func _on_play_again():
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()  # Stage bleibt 1 → neuer Run in Level 1


func _on_quit():
	GameStats.save_stats()
	get_tree().quit()
