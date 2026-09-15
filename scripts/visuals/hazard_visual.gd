extends Node2D

## Reskin note: this defines the obstacle's look only. Colors come from
## GameConfig (hazard_color / hazard_stripe_color). Swap this script for
## a zombie, rock, or traffic-cone shape without touching obstacle.gd's
## collision logic.

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var cfg: GameConfig = GameManager.config

	# Drop shadow
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(0, 34), 34, 10, 12), Color(0, 0, 0, 0.28))

	# Side face (implies depth)
	draw_colored_polygon(PackedVector2Array([
		Vector2(32, -24), Vector2(42, -16), Vector2(42, 30), Vector2(32, 28),
	]), cfg.hazard_color.darkened(0.32))

	# Top face (implies depth)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-32, -24), Vector2(32, -24), Vector2(42, -16), Vector2(-22, -16),
	]), cfg.hazard_color.lightened(0.18))

	# Front face (body)
	draw_colored_polygon(DrawUtils.rounded_rect_points(Rect2(-32, -16, 64, 44), 6), cfg.hazard_color)

	# Grille lines
	for i in range(3):
		var y: float = -4.0 + i * 10.0
		draw_line(Vector2(-24, y), Vector2(24, y), cfg.hazard_color.darkened(0.35), 3.0)

	# Warning stripe with hazard chevrons
	draw_rect(Rect2(-32, -16, 64, 8), cfg.hazard_stripe_color)
	for i in range(6):
		var x: float = -32.0 + i * 64.0 / 6.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, -16), Vector2(x + 10, -16), Vector2(x, -8),
		]), cfg.hazard_color.darkened(0.2))
