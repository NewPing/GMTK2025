extends CharacterBody2D

@export var speed: float = 120.0 
@export var dash_speed: float = 250.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 2.0

signal dash_progress_updated(progress: float)

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var _animated_sprite : AnimatedSprite2D
var is_current: bool = false
var is_caught: bool = false
var velocity_input: Vector2 = Vector2.ZERO

func _ready():
	_animated_sprite = $AnimatedSprite2D
	
func _physics_process(_delta: float) -> void:
	if is_current and not is_caught:
		var dir := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)
		velocity_input = dir.normalized() if dir.length() > 0.0 else Vector2.ZERO


		if dash_cooldown_timer > 0.0:
			dash_cooldown_timer -= _delta

		if not is_dashing and dash_cooldown_timer <= 0.0 and Input.is_action_just_pressed("dash") and velocity_input != Vector2.ZERO:
			is_dashing = true
			dash_timer = dash_duration
			dash_cooldown_timer = dash_cooldown
			emit_dash_progress()

		if is_dashing:
			velocity = velocity_input * dash_speed
			dash_timer -= _delta
			if dash_timer <= 0.0:
				is_dashing = false
		else:
			velocity = velocity_input * speed

		move_and_slide()
		emit_dash_progress()
	else:
		velocity_input = Vector2.ZERO
		velocity = Vector2.ZERO
		is_dashing = false
		dash_timer = 0.0
		dash_cooldown_timer = 0.0
		emit_dash_progress()
	play_animation_based_on_direction(velocity)
	
func emit_dash_progress() -> void:
	var progress: float = 0.0
	if dash_cooldown > 0:
		# If cooldown_timer is 0, it's ready (1.0). Otherwise, it's recharging (0.0 to 1.0)
		progress = 1.0 - (dash_cooldown_timer / dash_cooldown)
	emit_signal("dash_progress_updated", progress)

func play_animation_based_on_direction(velocity: Vector2):
	if(velocity == Vector2(0,0)):
		_animated_sprite.play("idle")
		return
	# Determine the direction based on the velocity
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			_animated_sprite.play("runRight")
		else:
			_animated_sprite.play("runLeft")
	else:
		if velocity.y > 0:
			_animated_sprite.play("runDown")
		else:
			_animated_sprite.play("runUp")


func set_current(value: bool) -> void:
	is_current = value

func mark_caught() -> void:
	is_caught = true
	is_current = false
