extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hurtbox = $Hurtbox


func _ready():
	hurtbox.hit.connect(die)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_dead:
		movement_controller()

	move_and_slide()


func _on_hazard_touched(_other):
	die()


func die():
	if is_dead:  # verhindert doppeltes Sterben
		return
	is_dead = true
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
