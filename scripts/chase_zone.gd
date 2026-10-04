extends Area2D
# Bewegt den Parent langsam zum Spieler, sobald dieser im Radius ist.
# Wände (Layer "environment") blockieren die Bewegung.

@export var radius := 80.0
@export var speed := 20.0
@export var horizontal_only := false
@export var target_offset := Vector2(0, -5)      # Körpermitte des Spielers
@export_flags_2d_physics var wall_mask := 1      # Layer 1 = environment
@export var body_radius := 5.0                   # Größe für den Wand-Test

var target: Node2D = null
var _test_shape := CircleShape2D.new()

@onready var shape_node = $CollisionShape2D


func _ready():
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape_node.shape = circle
	_test_shape.radius = body_radius
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.has_method("die"):  # nur der Player
		target = body


func _on_body_exited(body):
	if body == target:
		target = null


func _physics_process(delta):
	if target == null or target.is_dead:
		return
	var parent = get_parent()
	var pos: Vector2 = parent.global_position
	var goal: Vector2 = target.global_position + target_offset
	if horizontal_only:
		goal.y = pos.y

	var next := pos.move_toward(goal, speed * delta)
	if _is_free(next):
		parent.global_position = next
	elif _is_free(Vector2(next.x, pos.y)):  # an der Wand entlanggleiten
		parent.global_position = Vector2(next.x, pos.y)
	elif _is_free(Vector2(pos.x, next.y)):
		parent.global_position = Vector2(pos.x, next.y)


func _is_free(pos: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _test_shape
	query.transform = Transform2D(0.0, pos)
	query.collision_mask = wall_mask
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()
