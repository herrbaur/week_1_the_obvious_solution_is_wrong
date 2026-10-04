extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 60.0

var is_climbing := false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead := false
var _say_seq := 0
var _was_on_floor := false
var _squash_tween: Tween
const DustPuff = preload("res://scripts/dust_puff.gd")


@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var tile_map: TileMap = $"../TileMap"
@onready var speech_bubble: Node2D = $SpeechBubble
@onready var jump_sound = $JumpSound
@onready var land_sound = $LandSound  
@onready var die_sound: AudioStreamPlayer = $DieSound

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

	var fall_speed = velocity.y
	move_and_slide()

	if is_on_floor() and not _was_on_floor and fall_speed > 120.0 and not is_dead:
		land(fall_speed)
	_was_on_floor = is_on_floor()


func _on_hazard_touched(_other):
	die()


func die():
	if is_dead or GameStats.run_is_finished():  # verhindert doppeltes Sterben
		return
	is_dead = true
	is_climbing = false
	die_sound.play()
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
		jump()

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
			jump_sound.play()
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

func jump():
	velocity.y = JUMP_VELOCITY
	jump_sound.pitch_scale = randf_range(0.95, 1.05)  # klingt weniger monoton
	jump_sound.play()
	spawn_dust()
	squash_stretch(Vector2(0.8, 1.25))


func land(fall_speed: float):
	spawn_dust()
	land_sound.play()
	var strength = clampf(fall_speed / 500.0, 0.0, 0.3)  # härterer Aufprall, stärkerer Effekt
	squash_stretch(Vector2(1.0 + strength, 1.0 - strength))


func spawn_dust():
	var dust = DustPuff.new()
	get_parent().add_child(dust)
	dust.global_position = global_position


func squash_stretch(start_scale: Vector2):
	if _squash_tween:
		_squash_tween.kill()
	animated_sprite.scale = start_scale
	_squash_tween = create_tween()
	_squash_tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
func say_lines(lines: Array, duration := 3.0):
	_say_seq += 1
	var my_seq = _say_seq
	for line in lines:
		if my_seq != _say_seq:  # eine neuere Zeile wurde gestartet
			return
		await speech_bubble.show_text(line, duration)
	if my_seq == _say_seq:
		speech_bubble.hide_bubble()
