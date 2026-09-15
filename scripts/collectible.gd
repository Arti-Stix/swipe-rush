extends Area2D
class_name Collectible

## Reskin note: swap the "Visual" child's script for a coin, gem, or food
## item shape (see scripts/visuals/package_visual.gd). The pickup logic
## below never needs to change.

@export var value: int = 10
@onready var visual: Node2D = $Visual

var collected: bool = false

func _ready() -> void:
	if value <= 0:
		value = GameManager.config.collectible_value

func _on_body_entered(body: Node2D) -> void:
	if collected or not body.has_method("collect_item"):
		return
	collected = true
	body.collect_item(value)
	_spawn_pickup_feedback()
	_play_pickup_animation()

func _spawn_pickup_feedback() -> void:
	var popup := preload("res://scenes/score_popup.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position
	popup.show_value(value)

	var burst := preload("res://scenes/particle_burst.tscn").instantiate()
	get_tree().current_scene.add_child(burst)
	burst.global_position = global_position
	burst.burst(GameManager.config.package_tape_color)

func _play_pickup_animation() -> void:
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.4, 1.4), 0.08)
	tween.tween_property(visual, "scale", Vector2(0.0, 0.0), 0.12)
	tween.tween_callback(queue_free)
