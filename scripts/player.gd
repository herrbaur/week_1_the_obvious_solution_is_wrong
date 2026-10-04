extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 60.0

var is_climbing := false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false


@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var tile_map: TileMap = $"../TileMap"


func _ready():
	hurtbox.hit.connect(die)


func _physics_process(delta):
	if not is_dead:
		update_climbing()

	if not is_climbing and not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		pass
	elif is_climbing:
		climb_controller()
	else:
		movement_controller()

	move_and_slide()


func _on_hazard_touched(_other):
	die()


func die():
	if is_dead:  # verhindert doppeltes Sterben
		return
	is_dead = true
	is_climbing = false
	GameStats.add_death()
	print("You died!")
	Engine.time_scale = 0.5
	# set_deferred, weil wir mitten in einem Physik-Signal sind
	collision_shape.set_deferred("disabled", true)
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func movement_controller():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
func is_ladder_at(world_pos: Vector2) -> bool:
	if tile_map == null:
		return false
	var cell = tile_map.local_to_map(tile_map.to_local(world_pos))
	for layer in tile_map.get_layers_count():
		var data = tile_map.get_cell_tile_data(layer, cell)
		if data and data.get_custom_data("ladder"):
			return true
	return false


func update_climbing():
	var on_ladder = is_ladder_at(global_position + Vector2(0, -5))  # Körpermitte
	var climb_input = Input.get_axis("move_up", "move_down")

	if is_climbing:
		if not on_ladder:
			is_climbing = false
		elif Input.is_action_just_pressed("jump"):
			is_climbing = false
			velocity.y = JUMP_VELOCITY
		elif is_on_floor() and climb_input > 0:  # unten angekommen
			is_climbing = false
	elif on_ladder and climb_input != 0 and not (is_on_floor() and climb_input > 0):
		is_climbing = true
		velocity.y = 0


func climb_controller():
	var climb_input = Input.get_axis("move_up", "move_down")
	var direction = Input.get_axis("move_left", "move_right")

	# oben an der Leiter stoppen
	if climb_input < 0 and not is_ladder_at(global_position + Vector2(0, -12)):
		climb_input = 0

	velocity.y = climb_input * CLIMB_SPEED
	velocity.x = direction * CLIMB_SPEED

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	animated_sprite.play("idle")  # vorerst, später eigene "climb"-Animation
