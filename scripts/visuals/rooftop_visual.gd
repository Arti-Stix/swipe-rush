extends Node2D
class_name RooftopVisual

## Reskin note: colors come from GameConfig (rooftop_color_a / _b,
## lane_marking_color). This draws the converging pseudo-3D rooftop floor
## and the scrolling perspective lane dividers — the core of the
## "running toward a horizon" illusion.

@export var player_path: NodePath

const DASH_SLOTS := 10

var player: Player
var scroll_t: float = 0.0

func _ready() -> void:
	player = get_node(player_path)
	set_process(true)

func _process(delta: float) -> void:
	if GameManager.is_game_active:
		var cfg: GameConfig = GameManager.config
		var span: float = max(1.0, get_viewport_rect().size.y * (1.0 - cfg.horizon_ratio))
		scroll_t = fmod(scroll_t + (GameManager.current_speed * delta / span), 1.0 / DASH_SLOTS)
	queue_redraw()

func _draw() -> void:
	if player == null or player.lane_positions.is_empty():
		return
	var cfg: GameConfig = GameManager.config
	var size: Vector2 = get_viewport_rect().size
	var horizon_y: float = size.y * cfg.horizon_ratio
	var bottom_y: float = size.y
	var vanishing_x: float = size.x / 2.0

	var lane_positions: Array[float] = player.lane_positions
	var lane_width: float = cfg.lane_width
	var left_edge: float = lane_positions[0] - lane_width / 2.0
	var right_edge: float = lane_positions[lane_positions.size() - 1] + lane_width / 2.0

	# Converging rooftop floor (trapezoid, narrow at horizon, wide at player)
	draw_colored_polygon(PackedVector2Array([
		Vector2(vanishing_x - 4, horizon_y),
		Vector2(vanishing_x + 4, horizon_y),
		Vector2(right_edge, bottom_y),
		Vector2(left_edge, bottom_y),
	]), cfg.rooftop_color_a)

	# Alternating lane tint, each its own converging wedge
	for i in range(lane_positions.size()):
		if i % 2 == 1:
			var lane_left: float = lane_positions[i] - lane_width / 2.0
			var lane_right: float = lane_positions[i] + lane_width / 2.0
			draw_colored_polygon(PackedVector2Array([
				Vector2(vanishing_x, horizon_y),
				Vector2(vanishing_x, horizon_y),
				Vector2(lane_right, bottom_y),
				Vector2(lane_left, bottom_y),
			]), cfg.rooftop_color_b)

	# Rooftop ledges (outer converging edges, darker trim)
	draw_line(Vector2(vanishing_x - 6, horizon_y), Vector2(right_edge, bottom_y), cfg.rooftop_color_a.darkened(0.35), 4.0)
	draw_line(Vector2(vanishing_x + 6, horizon_y), Vector2(left_edge, bottom_y), cfg.rooftop_color_a.darkened(0.35), 4.0)

	# Scrolling perspective lane dividers (including the two outer edges)
	var divider_count: int = lane_positions.size() + 1
	for d in range(divider_count):
		var edge_x: float = left_edge + d * lane_width
		_draw_converging_dashes(vanishing_x, horizon_y, edge_x, bottom_y, cfg.lane_marking_color)

func _draw_converging_dashes(vx: float, vy: float, ex: float, ey: float, color: Color) -> void:
	var steps: int = DASH_SLOTS * 2
	for s in range(steps):
		var t0: float = float(s) / steps + scroll_t
		if t0 >= 1.0:
			continue
		var t1: float = min(t0 + 0.5 / steps, 1.0)
		var p0 := Vector2(lerp(vx, ex, t0), lerp(vy, ey, t0))
		var p1 := Vector2(lerp(vx, ex, t1), lerp(vy, ey, t1))
		var width: float = lerp(1.0, 5.0, t0)
		draw_line(p0, p1, color, width)
