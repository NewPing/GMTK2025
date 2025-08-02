extends CharacterBody2D

var detection_area: Area2D
var touch_area: Area2D
var ray: RayCast2D

signal player_touched(player: Node2D)

var player: Node2D = null
var player_in_cone := false
var player_visible := false
var busy_with_player := false
var _animated_sprite : AnimatedSprite2D

@export var speed: float = 120.0
@export var minigame_scene: PackedScene # assign MinigameQuickTime.tscn in Inspector

func _ready() -> void:
	detection_area = $Area2D_Vision
	touch_area = $Area2D_Touch
	ray = $RayCast2D
	_animated_sprite = $AnimatedSprite2D
	
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	touch_area.body_entered.connect(_on_touch_body_entered)
	
	ray.enabled = true
	ray.exclude_parent = true

func _on_detection_body_entered(body: Node) -> void:
	if body is Node2D and body.is_in_group("player") and not _is_player_caught(body):
		player = body
		player_in_cone = true

func _on_detection_body_exited(body: Node) -> void:
	if body == player:
		player_in_cone = false
		player_visible = false
		player = null

func _on_touch_body_entered(body: Node) -> void:
	if !busy_with_player:
		if body is Node2D and body.is_in_group("player") and not _is_player_caught(body):
			_on_player_touched(body)

func _on_player_touched(player: Node2D) -> void:
	player.set_physics_process(false)
	_start_minigame(player)

func _start_minigame(the_player: Node2D) -> void:
	if minigame_scene == null:
		return
	var ui := minigame_scene.instantiate()
	get_tree().get_root().add_child(ui)  # or a dedicated CanvasLayer/UI node
	ui.success.connect(_on_minigame_success)
	ui.fail.connect(_on_minigame_fail)
	ui.start(the_player, self)

func _on_minigame_success(player: Node2D, enemy: Node2D) -> void:
	if enemy != self: return
	busy_with_player = true                  # enemy is now occupied
	if is_instance_valid(player):
		# Treat as “busy” (first pass: reuse is_caught to remove it from control pool)
		if player.has_method("mark_caught"):
			player.call("mark_caught")
		emit_signal("player_touched", player)
		player.set_physics_process(true)

func _on_minigame_fail(player: Node2D, enemy: Node2D) -> void:
	if enemy != self: return
	# Player loses: mark caught; enemy remains active (no busy_with_player)
	if is_instance_valid(player):
		if player.has_method("mark_caught"):
			player.call("mark_caught")
		emit_signal("player_touched", player)
		player.set_physics_process(true)

func _physics_process(delta: float) -> void:
	if busy_with_player:
		_animated_sprite.play("idle")
		return
		
	player_visible = false

	if player_in_cone and is_instance_valid(player) and _is_player_caught(player):
		player_in_cone = false
		player_visible = false
		player = null

	if player_in_cone and is_instance_valid(player):
		var to_player := player.global_position - global_position
		
		detection_area.rotation = (player.global_position - detection_area.global_position).angle() - PI/2
		ray.global_position = global_position
		ray.target_position = to_player
		ray.force_raycast_update()

		var hit := ray.get_collider()
		if (hit == player or hit == null) and not _is_player_caught(player):
			player_visible = true

	if player_visible and is_instance_valid(player):
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO
		
	play_animation_based_on_direction(velocity)
	move_and_slide()

func _is_player_caught(p: Node) -> bool:
	return bool((p as Node).get("is_caught"))

func play_animation_based_on_direction(velocity: Vector2):
	if(velocity == Vector2(0,0)):
		_animated_sprite.play("idle")
		return
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
