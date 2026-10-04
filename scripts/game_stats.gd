extends Node
# Autoload "GameStats": überlebt Szenen-Reloads und speichert in user://

signal run_finished(time: float, rank: int)

const SAVE_PATH = "user://stats.cfg"
const MAX_ENTRIES = 10

var stage := 0                 # 0 = Tutorial, 1 = Level 1 (wird nicht gespeichert)
var deaths := 0
var best_time := -1.0          # = bester Eintrag der Highscore-Liste
var highscores: Array = []     # [{"time": float, "date": String}, ...], sortiert
var seen_dialogues := {}       # wird nicht gespeichert, gilt bis zum Spielende

var _saved_total_time := 0.0
var _session_start := 0
var _run_start := 0
var _run_frozen := -1.0
var _run_running := false


func _ready():
	_session_start = Time.get_ticks_msec()
	load_stats()


func start_run():
	_run_start = Time.get_ticks_msec()
	_run_frozen = -1.0
	_run_running = true


func stop_run():
	_run_running = false
	_run_frozen = -1.0


func finish_run():
	if not _run_running or _run_frozen >= 0.0:
		return
	_run_frozen = run_time()
	var rank = add_highscore(_run_frozen)
	save_stats()
	run_finished.emit(_run_frozen, rank)


func run_is_finished() -> bool:
	return _run_frozen >= 0.0


func add_death():
	if stage < 1:  # im Tutorial zählen Tode nicht
		return
	deaths += 1
	save_stats()


func add_highscore(time: float) -> int:
	var entry = {"time": time, "date": Time.get_date_string_from_system()}
	highscores.append(entry)
	highscores.sort_custom(func(a, b): return a["time"] < b["time"])
	if highscores.size() > MAX_ENTRIES:
		highscores.resize(MAX_ENTRIES)
	best_time = highscores[0]["time"]
	return highscores.find(entry)  # -1, wenn nicht in den Top 10


func run_time() -> float:
	if not _run_running:
		return 0.0
	if _run_frozen >= 0.0:
		return _run_frozen
	return (Time.get_ticks_msec() - _run_start) / 1000.0


func total_time() -> float:
	return _saved_total_time + (Time.get_ticks_msec() - _session_start) / 1000.0


func format_time(t: float) -> String:
	if t < 0.0:
		return "--:--.--"
	var minutes := int(t / 60.0)
	var seconds := int(t) % 60
	var hundredths := int((t - int(t)) * 100.0)
	return "%d:%02d.%02d" % [minutes, seconds, hundredths]


func reset_all_stats():
	deaths = 0
	best_time = -1.0
	highscores.clear()
	_saved_total_time = 0.0
	_session_start = Time.get_ticks_msec()
	save_stats()


func save_stats():
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "deaths", deaths)
	cfg.set_value("stats", "total_time", total_time())
	cfg.set_value("stats", "highscores", highscores)
	cfg.save(SAVE_PATH)


func load_stats():
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	deaths = cfg.get_value("stats", "deaths", 0)
	_saved_total_time = cfg.get_value("stats", "total_time", 0.0)
	highscores = cfg.get_value("stats", "highscores", [])
	best_time = highscores[0]["time"] if not highscores.is_empty() else -1.0


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_stats()


func _unhandled_input(event):
	# Nur im Editor / Debug-Build: F9 setzt alle gespeicherten Werte zurück
	if OS.is_debug_build() and event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		reset_all_stats()
		print("GameStats: alle Werte zurückgesetzt")
