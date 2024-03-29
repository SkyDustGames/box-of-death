extends CharacterBody2D

signal died()

@onready var canvas = $"../../CanvasLayer"
@onready var health_bar = $"../../CanvasLayer/HealthBar"

@export var speed: float
@export var jump_velocity: float
@export var camera_should_follow = true
@export var bossfight = false
@export var boss_dead = false
var camera: Camera2D
var health = 1.0
var frozen: bool
var death_explosion = preload("res://nodes/death_explosion.tscn")
var dmg_explosion = preload("res://nodes/damage_explosion.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	camera = get_viewport().get_camera_2d()

func _physics_process(delta):
	if frozen: return
	
	if not is_on_floor():
		velocity.y += gravity * delta
		$Sprite2D.frame = 1
	else: $Sprite2D.frame = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
		AudioManager.play_sound("res://audio/jump.wav")

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	if camera_should_follow:
		camera.position = global_position
	
	if position.y >= 1000:
		damage(1, false)

func damage(amount: float, success: bool):
	if bossfight and not boss_dead: success = false
	if health <= 0: return
	health -= amount
	health_bar.value = health
	if health <= 0:
		died.emit()
		hide()
		frozen = true
		$"../../Setup/CustomTimer".set_process(false)
		var explosion = death_explosion.instantiate()
		explosion.position = global_position
		add_sibling(explosion)
		AudioManager.play_sound("res://audio/explosion.wav")
		if bossfight and boss_dead:
			await get_tree().create_timer(3).timeout
			SceneManager.change_scene("res://scenes/thanks.tscn")
			return
		await get_tree().create_timer(1).timeout
		canvas.finish(success)
		return
	AudioManager.play_sound("res://audio/hitHurt.wav")
	var explosion = dmg_explosion.instantiate()
	explosion.position = global_position
	add_sibling(explosion)

func _play_walk_sound():
	if velocity.x != 0 and is_on_floor():
		AudioManager.play_sound("res://audio/walk.wav")
