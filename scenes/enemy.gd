extends CharacterBody2D

@onready var detection_area: Area2D = $Area2D_Vision
@onready var touch_area: Area2D = $Area2D_Touch
@onready var ray: RayCast2D = $RayCast2D

signal player_touched(player: Node2D)

var player: Node2D = null
var player_in_cone := false
var player_visible := false
var busy_with_player := false

@export var speed: float = 120.0

func _ready() -> void:
	# Vision cone signals
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

	# Touch signals
	if touch_area:
		touch_area.body_entered.connect(_on_touch_body_entered)

	# Prevent ray from hitting self
	ray.enabled = true
	ray.exclude_parent = true

func _on_detection_body_entered(body: Node) -> void:
	if body is Node2D and body.is_in_group("player") and not _is_player_caught(body): # [CHANGED L28]
		player = body
		player_in_cone = true

func _on_detection_body_exited(body: Node) -> void:
	if body == player:
		player_in_cone = false
		player_visible = false
		player = null

func _on_touch_body_entered(body: Node) -> void:
	if !busy_with_player:
		if body is Node2D and body.is_in_group("player") and not _is_player_caught(body): # [CHANGED L45]
			_on_player_touched(body)

func _on_player_touched(the_player: Node2D) -> void:
	# Placeholder: trigger "something" when touched
	emit_signal("player_touched", the_player)

	# Example tiny freeze to show it's working (remove later)
	busy_with_player = true

func _physics_process(delta: float) -> void:
	if busy_with_player:
		return
		
	player_visible = false

	# If our tracked player became caught, forget them
	if player_in_cone and is_instance_valid(player) and _is_player_caught(player): # [CHANGED L72]
		player_in_cone = false
		player_visible = false
		player = null

	if player_in_cone and is_instance_valid(player):
		var to_player := player.global_position - global_position
		#rotate vision cone towards player position
		detection_area.rotation = (player.global_position - detection_area.global_position).angle() - PI/2
		ray.global_position = global_position
		ray.target_position = to_player
		ray.force_raycast_update()

		var hit := ray.get_collider()
		# Visible if first hit is the player or nothing
		if (hit == player or hit == null) and not _is_player_caught(player): # [CHANGED L86]
			player_visible = true

	# Chase if visible
	if player_visible and is_instance_valid(player):
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _is_player_caught(p: Node) -> bool: # [ADDED L103-L106]
	# Assumes players share a script with a boolean property "is_caught"
	return bool((p as Node).get("is_caught"))
