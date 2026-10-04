extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

var collected := false


func _on_body_entered(body):
	if collected or not body.has_method("die"):  # nur der Spieler
		return
	collected = true
	game_manager.add_point()
	animation_player.play("pickup")
