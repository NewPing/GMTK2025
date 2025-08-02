extends CharacterBody2D

@export var speed: float = 120.0 
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
		velocity = velocity_input * speed
		move_and_slide()
	else:
		velocity_input = Vector2.ZERO
		velocity = Vector2.ZERO
	play_animation_based_on_direction(velocity)

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
