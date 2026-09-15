extends RefCounted
class_name DrawUtils

## Shared geometry helpers for the procedural (no-texture) art style.
## Every visual script (player, package, hazard, skyline, clouds) uses
## these so the whole game keeps one consistent "rounded vector" look.

static func rounded_rect_points(rect: Rect2, radius: float, corner_segments: int = 6) -> PackedVector2Array:
	var points := PackedVector2Array()
	var r: float = min(radius, min(rect.size.x, rect.size.y) / 2.0)
	var corners: Array[Vector2] = [
		Vector2(rect.position.x + rect.size.x - r, rect.position.y + r),
		Vector2(rect.position.x + rect.size.x - r, rect.position.y + rect.size.y - r),
		Vector2(rect.position.x + r, rect.position.y + rect.size.y - r),
		Vector2(rect.position.x + r, rect.position.y + r),
	]
	var start_angles: Array[float] = [-PI / 2.0, 0.0, PI / 2.0, PI]
	for c in range(4):
		var center: Vector2 = corners[c]
		var start_angle: float = start_angles[c]
		for s in range(corner_segments + 1):
			var angle: float = start_angle + (PI / 2.0) * (float(s) / corner_segments)
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
	return points

static func ellipse_points(center: Vector2, rx: float, ry: float, segments: int = 16) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(segments):
		var angle: float = TAU * float(i) / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points
