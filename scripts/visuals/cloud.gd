extends Node2D

## Cheap ambient life for the background. Purely decorative, no gameplay
## impact — safe to add/remove/duplicate freely.

@export var speed: float = 12.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	position.x -= speed * delta
	var viewport_width: float = get_viewport_rect().size.x
	if position.x < -140.0:
		position.x = viewport_width + 140.0

func _draw() -> void:
	var c := Color(1, 1, 1, 0.85)
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(-30, 0), 32, 18, 14), c)
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(10, -8), 26, 16, 14), c)
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(30, 4), 30, 16, 14), c)
