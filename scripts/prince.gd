extends CharacterBody2D 

@export var speed: float = 180.0 
var _animated_sprite : AnimatedSprite2D
func _ready():
	_animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	dir = dir.normalized() if dir.length() > 0 else Vector2.ZERO 
	velocity = dir * speed
	_play_animation_based_on_direction(velocity)
	move_and_slide()

func _play_animation_based_on_direction(velocity: Vector2):
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
