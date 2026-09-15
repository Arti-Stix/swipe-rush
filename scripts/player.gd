extends CharacterBody2D
class_name Player

## Reskin note: swap the "Visual" child node for your own sprite/
## AnimatedSprite2D. Nothing else in this script cares what the player looks like.

var config: GameConfig
var current_lane: int = 1
var target_x: float = 0.0
var lane_positions: Array[float] = []

var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var lane_tween: Tween = null

@onready var visual: Node2D = $Visual

func _ready() -> void:
	config = GameManager.config
	_setup_lanes()
	position.x = lane_positions[current_lane]
	target_x = position.x
	GameManager.obstacle_hit.connect(_on_obstacle_hit)

func _setup_lanes() -> void:
	lane_positions.clear()
	var screen_center_x: float = get_viewport_rect().size.x / 2.0
	var total_width := config.lane_width * (config.lane_count - 1)
	var start_x := screen_center_x - total_width / 2.0
	for i in range(config.lane_count):
		lane_positions.append(start_x + i * config.lane_width)
	current_lane = int(config.lane_count / 2)

func _input(event: InputEvent) -> void:
	if not GameManager.is_game_active:
		return

	# --- Mobile touch ---
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_pos = event.position
		else:
			is_dragging = false
	elif event is InputEventScreenDrag:
		if is_dragging:
			var delta_x: float = event.position.x - drag_start_pos.x
			if abs(delta_x) > config.swipe_threshold:
				_try_switch_lane(sign(delta_x))
				drag_start_pos = event.position

	# --- Desktop mouse (drag emulates swipe) ---
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if event.pressed:
			drag_start_pos = event.position
	elif event is InputEventMouseMotion and is_dragging:
		var delta_x: float = event.position.x - drag_start_pos.x
		if abs(delta_x) > config.swipe_threshold:
			_try_switch_lane(sign(delta_x))
			drag_start_pos = event.position

	# --- Desktop keyboard (fast testing) ---
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT or event.keycode == KEY_A:
			_try_switch_lane(-1)
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			_try_switch_lane(1)

func _try_switch_lane(direction: float) -> void:
	var new_lane: int = clampi(current_lane + int(direction), 0, config.lane_count - 1)
	if new_lane != current_lane:
		current_lane = new_lane
		target_x = lane_positions[current_lane]

		# Snap between lanes quickly instead of using a floaty frame-by-frame lerp.
		if lane_tween and lane_tween.is_valid():
			lane_tween.kill()

		lane_tween = create_tween()
		lane_tween.set_trans(Tween.TRANS_QUAD)
		lane_tween.set_ease(Tween.EASE_OUT)
		lane_tween.tween_property(self, "position:x", target_x, 0.09)

		_play_lane_switch_juice(sign(direction))

func _play_lane_switch_juice(direction: float) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector2(0.8, 1.15), 0.08)
	tween.tween_property(visual, "rotation", deg_to_rad(14.0 * direction), 0.08)
	tween.chain().set_parallel(true)
	tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.15)
	tween.tween_property(visual, "rotation", 0.0, 0.15)

func _on_obstacle_hit() -> void:
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.25)

func _physics_process(_delta: float) -> void:
	# Lane movement is handled by the short tween in _try_switch_lane().
	pass

func hit_obstacle() -> void:
	GameManager.lose_game()

func collect_item(value: int) -> void:
	GameManager.add_score(value)
