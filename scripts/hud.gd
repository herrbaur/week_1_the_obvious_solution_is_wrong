extends CanvasLayer

@onready var game_manager = get_node("../GameManager")
@onready var coins_label = $MarginContainer/VBoxContainer/CoinsLabel
@onready var deaths_label = $MarginContainer/VBoxContainer/DeathsLabel
@onready var run_label = $MarginContainer/VBoxContainer/RunLabel
@onready var best_label = $MarginContainer/VBoxContainer/BestLabel
@onready var total_label = $MarginContainer/VBoxContainer/TotalLabel


func _process(_delta):
	coins_label.text = "Coins: %d" % game_manager.score
	deaths_label.text = "Deaths: %d" % GameStats.deaths
	run_label.text = "Run: " + GameStats.format_time(GameStats.run_time())
	best_label.text = "Best: " + GameStats.format_time(GameStats.best_time)
	total_label.text = "Total: " + GameStats.format_time(GameStats.total_time())

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		GameStats.finish_run()  # nur zum Testen, später entfernen
