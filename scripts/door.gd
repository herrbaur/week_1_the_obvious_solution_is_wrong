extends Area2D

enum Kind { TO_LEVEL_1, EXIT }

@export var kind: Kind = Kind.TO_LEVEL_1
@export var requires_no_coins := false
@export_multiline var denied_text := "Halt! Mit Burggold kommst du hier nicht raus! Komm mit leeren Taschen wieder. (R = von vorn)"
@export_multiline var accepted_text := "Leere Taschen? Gut. Geh durch, Ritter."

var player = null
var _say_id := 0


@onready var game_manager = %GameManager
@onready var prompt = $Prompt
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speech_bubble: Node2D = $SpeechBubble



func _ready():
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.has_method("die"):
		player = body
		prompt.show()


func _on_body_exited(body):
	if body == player:
		player = null
		prompt.hide()


func _unhandled_input(event):
	if player != null and event.is_action_pressed("interact"):
		use_door()


func use_door():
	print("use_door: kind=", kind, ", stage vorher=", GameStats.stage)
	if player.is_dead:
		return
	if requires_no_coins and game_manager.score > 0:
		say(denied_text)
		return
	match kind:
		Kind.TO_LEVEL_1:
			animated_sprite.play("open")
			await get_tree().create_timer(0.5).timeout
			GameStats.stage = 1
			game_manager.reset_level()
		Kind.EXIT:
			animated_sprite.play("open")
			await get_tree().create_timer(0.5).timeout
			GameStats.finish_run()
			say(accepted_text)


func say(text: String):
	await speech_bubble.show_text(text, 5.0)
	speech_bubble.hide_bubble()
