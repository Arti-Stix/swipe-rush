extends Camera2D
class_name ShakeCamera

var shake_strength: float = 0.0

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = max(shake_strength - delta * 40.0, 0.0)
		if shake_strength <= 0.0:
			offset = Vector2.ZERO

func shake(amount: float) -> void:
	shake_strength = amount
