extends Node2D

var players: Array[Node2D] = []
var current_index: int = 0

@onready var camera: Camera2D = $Camera2D
@onready var dash_ui: Control = $Camera2D/DashCooldownDisplay
@onready var DeathScreen: Control = $Camera2D/Deathscreen
@onready var musicPlayer : AudioStreamPlayer2D = $musicPlayer

func _ready() -> void:
	var raw_players: Array = get_tree().get_nodes_in_group("player")
	players.clear()
	for n in raw_players:
		if n is Node2D:
			players.append(n)

	players.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return String(a.name) < String(b.name)
	)

	if players.is_empty():
		push_warning("No players found in 'player' group.")
		return

	current_index = clamp(current_index, 0, players.size() - 1)
	for i in range(players.size()):
		players[i].call("set_current", i == current_index)

	_connect_dash_ui_to_player(players[current_index])
	_attach_camera_to(players[current_index])

	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e and e.has_signal("player_touched"):
			e.player_touched.connect(_on_player_caught)

func _process(delta: float) -> void:
	var curr: Node2D = _current_player()
	if curr and camera:
		camera.global_position = curr.global_position

func _connect_dash_ui_to_player(player_node: Node2D) -> void: # NEW Function
	# Disconnect previous player's signal if any
	for p in players: # Iterate all players to disconnect any existing connection
		if p.is_connected("dash_progress_updated", _on_player_dash_progress_updated):
			p.disconnect("dash_progress_updated", _on_player_dash_progress_updated)

	# Connect new player's signal
	if player_node and dash_ui:
		# Check if the player actually has the signal (e.g., if he's a PrinceCharacter)
		if player_node.has_signal("dash_progress_updated"):
			player_node.connect("dash_progress_updated", _on_player_dash_progress_updated)
			# Immediately update the UI with current state
			player_node.call("emit_dash_progress") # Request initial update

func _on_player_dash_progress_updated(progress: float) -> void: # NEW Function
	if dash_ui:
		dash_ui.call("update_progress", progress)

func _current_player() -> Node2D:
	if current_index >= 0 and current_index < players.size():
		return players[current_index]
	return null

func _attach_camera_to(target: Node2D) -> void:
	if not camera or not target:
		return
	camera.global_position = target.global_position
	camera.make_current()

func _on_player_caught(caught_player: Node2D) -> void:
	if is_instance_valid(caught_player):
		caught_player.call("set_current", false)
		if caught_player.has_method("mark_caught"):
			caught_player.call("mark_caught")
	
	var next_index: int = _find_nearest_uncaught_index(caught_player)
	if next_index == -1:
		showDeathScreen()
		return
	
	current_index = next_index
	
	for i in range(players.size()):
		players[i].call("set_current", i == current_index)
	
	_connect_dash_ui_to_player(players[current_index])
	
	_attach_camera_to(players[current_index])
	
func showDeathScreen() -> void:
	DeathScreen.visible = true
	musicPlayer.volume_db -= 10

func _find_nearest_uncaught_index(exclude_player: Node2D) -> int:
	var best_idx: int = -1
	var best_dist: float = INF
	var ref_pos: Vector2 = exclude_player.global_position if is_instance_valid(exclude_player) else camera.global_position

	for i in range(players.size()):
		var p: Node2D = players[i]
		if p == exclude_player:
			continue

		var uncaught: bool = false
		uncaught = not (p as Node).get("is_caught")

		if not uncaught:
			continue

		var d: float = ref_pos.distance_to(p.global_position)
		if d < best_dist:
			best_dist = d
			best_idx = i

	return best_idx
