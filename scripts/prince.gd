extends CharacterBody2D

@export var speed: float = 180.0
var is_current: bool = false
var is_caught: bool = false
var velocity_input: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D  # adjust if different

func set_current(value: bool) -> void:
	is_current = value

func mark_caught() -> void:
	is_caught = true
	is_current = false
	# Optional: play a "caught" animation if you have it
	if anim and "caught" in anim.sprite_frames.get_animation_names():
		anim.play("caught")

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

	_update_animation()

func _update_animation() -> void:
	if anim == null:
		return
	if is_caught:
		if "caught" in anim.sprite_frames.get_animation_names():
			anim.play("caught")
		else:
			anim.play("idle")
		return

	if is_current and velocity_input.length() > 0.0:
		anim.play("walk")
	else:
		anim.play("idle")
