extends Node2D

## Reskin note: colors come from GameConfig (sky_color_top / sky_color_bottom
## / skyline_color). `seed_value` controls the (fixed, non-random-each-frame)
## building layout — change it for a different skyline arrangement.

@export var seed_value: int = 1337

func _ready() -> void:
	queue_redraw()
	get_viewport().size_changed.connect(func(): queue_redraw())

func _draw() -> void:
	var cfg: GameConfig = GameManager.config
	var size: Vector2 = get_viewport_rect().size
	var horizon_y: float = size.y * cfg.horizon_ratio

	# Sky gradient (banded approximation, cheap to draw)
	var bands := 20
	for i in range(bands):
		var t0: float = float(i) / bands
		var t1: float = float(i + 1) / bands
		var color: Color = cfg.sky_color_top.lerp(cfg.sky_color_bottom, t0)
		draw_rect(Rect2(0, t0 * horizon_y, size.x, (t1 - t0) * horizon_y + 1.0), color)

	# Deterministic skyline so it looks the same every run (not noisy/random each frame)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var x: float = -20.0
	while x < size.x + 20.0:
		var w: float = rng.randf_range(50, 110)
		var h: float = rng.randf_range(60, 220)
		draw_rect(Rect2(x, horizon_y - h, w, h), cfg.skyline_color)

		var wx: float = x + 8.0
		while wx < x + w - 12.0:
			var wy: float = horizon_y - h + 12.0
			while wy < horizon_y - 12.0:
				if rng.randf() < 0.5:
					draw_rect(Rect2(wx, wy, 6, 8), cfg.skyline_color.lightened(0.5).lerp(Color(1, 0.9, 0.6), 0.6))
				wy += 16.0
			wx += 14.0

		if rng.randf() < 0.3:
			var antenna_x: float = x + w / 2.0
			var antenna_top: float = horizon_y - h - 26.0
			draw_line(Vector2(antenna_x, horizon_y - h), Vector2(antenna_x, antenna_top), cfg.skyline_color.darkened(0.2), 2.0)
			draw_circle(Vector2(antenna_x, antenna_top), 3.0, Color(1, 0.3, 0.3, 0.85))

		x += w + rng.randf_range(10, 30)

	# Horizon highlight strip
	draw_rect(Rect2(0, horizon_y - 3, size.x, 3), cfg.sky_color_bottom.lightened(0.1))
