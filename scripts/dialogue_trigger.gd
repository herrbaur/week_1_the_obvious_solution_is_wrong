extends Area2D

@export var dialogue_id := ""
@export var lines: Array[String] = []   # optional: überschreibt die ID
@export var once := true
@export var duration := 3.0


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body.has_method("say_lines"):
		return

	var key = str(get_path())
	if once and GameStats.seen_dialogues.has(key):
		return

	var text_lines = lines if not lines.is_empty() else Dialogues.LINES.get(dialogue_id, [])
	if text_lines.is_empty():
		push_warning("Kein Text für Dialog-ID: '" + dialogue_id + "'")
		return

	if once:
		GameStats.seen_dialogues[key] = true
	body.say_lines(text_lines, duration)
