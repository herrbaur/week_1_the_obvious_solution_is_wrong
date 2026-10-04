extends Node2D
@onready var animated_sprite = $AnimatedSprite2D

func _on_killzone_body_entered(_body: Node2D) -> void:
	animated_sprite.play("blood")
