extends CharacterBody2D 

@export var speed: float = 180.0 

func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	dir = dir.normalized() if dir.length() > 0 else Vector2.ZERO 
	velocity = dir * speed
	move_and_slide()
