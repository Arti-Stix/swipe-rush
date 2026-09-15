extends Area2D
class_name Obstacle

## Reskin note: swap the "Visual" child's script for your own hazard shape
## (see scripts/visuals/hazard_visual.gd). The collision behavior below
## never needs to change.

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hit_obstacle"):
		_spawn_impact_feedback()
		body.hit_obstacle()

func _spawn_impact_feedback() -> void:
	var burst := preload("res://scenes/particle_burst.tscn").instantiate()
	get_tree().current_scene.add_child(burst)
	burst.global_position = global_position
	burst.burst(GameManager.config.hazard_stripe_color)
