extends Node2D

## Reskin note: this is the ONLY file that defines what the player looks
## like. Colors come from GameConfig (player_color / player_accent_color)
## — change those in the Inspector for a full recolor, or replace this
## script's _draw() body entirely for a different silhouette.

var run_time: float = 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if GameManager.is_game_active:
		var speed_ratio: float = GameManager.current_speed / max(GameManager.config.forward_speed, 1.0)
		run_time += delta * (8.0 + speed_ratio * 3.0)
	queue_redraw()

func _draw() -> void:
	var cfg: GameConfig = GameManager.config
	var body_color: Color = cfg.player_color
	var accent: Color = cfg.player_accent_color

	var bob: float = sin(run_time) * 3.0
	var leg_phase: float = sin(run_time)

	# Drop shadow (stays put, doesn't bob)
	draw_colored_polygon(DrawUtils.ellipse_points(Vector2(0, 48), 30, 10, 14), Color(0, 0, 0, 0.25))

	# Legs (alternating running stride)
	draw_rect(Rect2(-16, 18 + leg_phase * 6.0, 13, 26), Color(0.16, 0.17, 0.22))
	draw_rect(Rect2(3, 18 - leg_phase * 6.0, 13, 26), Color(0.16, 0.17, 0.22))

	# Backpack (drawn behind torso)
	draw_colored_polygon(DrawUtils.rounded_rect_points(Rect2(-26, -6 + bob, 20, 38), 6), accent.darkened(0.15))

	# Torso
	draw_colored_polygon(DrawUtils.rounded_rect_points(Rect2(-24, -30 + bob, 48, 56), 12), body_color)
	draw_rect(Rect2(-24, -6 + bob, 48, 6), body_color.darkened(0.12)) # belt line

	# Head
	draw_circle(Vector2(0, -46 + bob), 16, Color(0.93, 0.78, 0.63))

	# Cap
	draw_colored_polygon(DrawUtils.rounded_rect_points(Rect2(-17, -60 + bob, 34, 16), 7), accent)
	draw_rect(Rect2(-17, -47 + bob, 34, 4), accent)
