extends Node2D
@onready var animated_sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.


func _on_killzone_body_entered(body: Node2D) -> void:
	animated_sprite.play("blood")


func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
