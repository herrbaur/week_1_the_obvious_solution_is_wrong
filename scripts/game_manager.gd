extends Node

const SPAWN_NAMES = ["Tutorial", "Level1"]

var score = 0

@onready var player = get_node("../Player")


func _ready():
	var spawn_name = SPAWN_NAMES[GameStats.stage]
	var spawn = get_node_or_null("../Spawns/" + spawn_name)
	print("Stage=", GameStats.stage, ", Spawn=", spawn_name, ", gefunden=", spawn != null)
	if spawn:
		print("Spawn-Position: ", spawn.global_position)
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_warning("Spawn nicht gefunden: " + spawn_name)

	if GameStats.stage >= 1:
		GameStats.start_run()
	else:
		GameStats.stop_run()


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		reset_level()


func reset_level():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func add_point():
	score += 1
