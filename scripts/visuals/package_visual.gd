extends Node2D

## Reskin note: this defines the collectible's look only. Colors come
## from GameConfig (package_color / package_tape_color). Swap this
## script for a coin, gem, or food-item shape without touching
## collectible.gd's pickup logic.

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var cfg: GameConfig = GameManager.config

	# Drop shadow
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(0, 22), 22, 8, 12), Color(0, 0, 0, 0.25))

	# Side face (implies depth)
	draw_colored_polygon(PackedVector2Array([
		Vector2(22, -22), Vector2(30, -16), Vector2(30, 22), Vector2(22, 22),
	]), cfg.package_color.darkened(0.28))

	# Top face (implies depth)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-22, -22), Vector2(22, -22), Vector2(30, -16), Vector2(-14, -16),
	]), cfg.package_color.lightened(0.22))

	# Front face
	draw_colored_polygon(DrawUtils.rounded_rect_points(Rect2(-22, -16, 44, 38), 4), cfg.package_color)

	# Tape cross on the front face
	draw_rect(Rect2(-22, 1, 44, 6), cfg.package_tape_color)
	draw_rect(Rect2(-2, -16, 6, 38), cfg.package_tape_color)

	# Highlight along the front top edge
	draw_rect(Rect2(-22, -16, 44, 4), cfg.package_color.lightened(0.35))
