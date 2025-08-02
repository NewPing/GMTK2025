extends Control
class_name MinigameQuickTime

signal success(player: Node2D, enemy: Node2D)
signal fail(player: Node2D, enemy: Node2D)

@export var duration: float = 1.5            # seconds for full bar traversal (left→right)
@export var hit_zone_width: float = 160.0
@export var cursor_speed_scale: float = 1.0
@export var auto_close_on_result: bool = true

var _running: bool = false
var _dir: int = 1              # 1 = right, -1 = left
var _player: Node2D
var _enemy: Node2D
var _cursor_x: float = 0.0     # current x in local bar coordinates

@onready var bar: ColorRect = $CanvasLayer/SliderRoot/CursorOutline/Bar
@onready var hit_zone: ColorRect = $CanvasLayer/SliderRoot/CursorOutline/HitZone
@onready var cursor: ColorRect = $CanvasLayer/SliderRoot/CursorOutline/Cursor

func start(player: Node2D, enemy: Node2D) -> void:
	_player = player
	_enemy = enemy
	_running = true
	visible = true

	# Place the hit zone randomly
	var bar_width := bar.size.x
	var hz_w: float = clamp(hit_zone_width, 20.0, bar_width - 20.0)
	var hz_x := randf_range(10.0, bar_width - hz_w - 10.0)
	hit_zone.position.x = hz_x
	hit_zone.size.x = hz_w

	# Reset cursor at left edge, moving right
	_cursor_x = 0.0
	_dir = 1
	cursor.position.x = _cursor_x

func _ready() -> void:
	visible = false
	anchor_left = 0.5; anchor_right = 0.5; anchor_top = 0.85; anchor_bottom = 0.85
	offset_left = -200; offset_right = 200; offset_top = -30; offset_bottom = 30

func _process(delta: float) -> void:
	if not _running:
		return

	# Compute speed from duration: full width in 'duration' seconds.
	var bar_width: float = bar.size.x
	var cursor_w: float = cursor.size.x
	var max_x: float = bar_width - cursor_w
	var speed: float = (bar_width / max(0.001, duration)) * cursor_speed_scale

	# Update position with direction
	_cursor_x += speed * delta * float(_dir)

	# Bounce at edges (ping-pong)
	if _cursor_x <= 0.0:
		_cursor_x = 0.0
		_dir = 1
	elif _cursor_x >= max_x:
		_cursor_x = max_x
		_dir = -1

	cursor.position.x = _cursor_x

func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("space"):
		# Check if cursor center is inside hit zone
		var cursor_center_x := cursor.global_position.x + cursor.size.x * 0.5
		var zone_left := hit_zone.global_position.x
		var zone_right := zone_left + hit_zone.size.x
		var ok := cursor_center_x >= zone_left and cursor_center_x <= zone_right
		_finish(ok)

func _finish(ok: bool) -> void:
	_running = false
	if ok:
		emit_signal("success", _player, _enemy)
	else:
		emit_signal("fail", _player, _enemy)
	if auto_close_on_result:
		queue_free()
	else:
		visible = false
