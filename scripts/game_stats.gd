extends Node
# Autoload "GameStats": überlebt Szenen-Reloads und speichert in user://

const SAVE_PATH = "user://stats.cfg"

var deaths := 0
var best_time := -1.0            # -1 = noch keine Bestzeit
var _saved_total_time := 0.0     # Gesamtzeit aus früheren Sitzungen
var _session_start := 0          # Millisekunden
var stage := 0                 # 0 = Tutorial, 1 = Level 1 (wird nicht gespeichert)
var _run_running := false
var _run_start := 0
var _run_frozen := -1.0          # >= 0, sobald der Run beendet ist
var seen_dialogues := {}   # wird nicht gespeichert, gilt nur bis zum Spielende


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
	if best_time < 0.0 or _run_frozen < best_time:
		best_time = _run_frozen
	save_stats()


func add_death():
	if stage < 1:  # Tode im Tutorial zählen nicht
		return
	deaths += 1
	save_stats()


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


func save_stats():
	var cfg := ConfigFile.new()
	cfg.set_value("stats", "deaths", deaths)
	cfg.set_value("stats", "best_time", best_time)
	cfg.set_value("stats", "total_time", total_time())
	cfg.save(SAVE_PATH)


func load_stats():
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	deaths = cfg.get_value("stats", "deaths", 0)
	best_time = cfg.get_value("stats", "best_time", -1.0)
	_saved_total_time = cfg.get_value("stats", "total_time", 0.0)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_stats()
