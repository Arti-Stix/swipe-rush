extends Node

## Autoload singleton (see project.godot [autoload]).
## Holds all run-time game state and fires signals the UI/scenes listen to.
## This is also where ad-SDK / analytics calls should eventually be plugged in
## — see _log_analytics_event() at the bottom.

signal score_changed(new_score: int)
signal combo_changed(multiplier: float)
signal distance_changed(distance: float, total: float)
signal game_started
signal game_won
signal game_lost
signal obstacle_hit

var config: GameConfig = preload("res://config/default_config.tres")

const SAVE_PATH := "user://rooftop_rush_save.dat"

var score: int = 0
var best_score: int = 0
var combo_multiplier: float = 1.0
var combo_timer: float = 0.0
var distance_traveled: float = 0.0
var current_speed: float = 0.0
var is_game_active: bool = false
var last_checkpoint: float = 0.0

func _ready() -> void:
	_load_best_score()

func _load_best_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best_score = file.get_32()
			file.close()

func _save_best_score() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(best_score)
		file.close()

func _check_best_score() -> void:
	if score > best_score:
		best_score = score
		_save_best_score()

func _process(delta: float) -> void:
	if not is_game_active:
		return
	if combo_multiplier > 1.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_multiplier = 1.0
			combo_changed.emit(combo_multiplier)

func start_game() -> void:
	score = 0
	combo_multiplier = 1.0
	combo_timer = 0.0
	distance_traveled = 0.0
	last_checkpoint = 0.0
	current_speed = config.forward_speed
	is_game_active = true
	score_changed.emit(score)
	combo_changed.emit(combo_multiplier)
	distance_changed.emit(distance_traveled, config.level_length)
	game_started.emit()
	_log_analytics_event("game_start", {})

func add_score(base_value: int) -> void:
	if not is_game_active:
		return
	var earned := int(base_value * combo_multiplier)
	score += earned
	combo_multiplier = min(combo_multiplier + config.combo_multiplier_step, config.combo_max_multiplier)
	combo_timer = config.combo_reset_time
	score_changed.emit(score)
	combo_changed.emit(combo_multiplier)

func advance(delta: float) -> void:
	if not is_game_active:
		return
	current_speed = min(current_speed + config.speed_increase_per_second * delta, config.max_forward_speed)
	distance_traveled += current_speed * delta
	distance_changed.emit(distance_traveled, config.level_length)

	if distance_traveled - last_checkpoint >= config.checkpoint_interval:
		last_checkpoint = distance_traveled
		_log_analytics_event("checkpoint_reached", {"distance": distance_traveled})

	if distance_traveled >= config.level_length:
		win_game()

func lose_game() -> void:
	if not is_game_active:
		return
	is_game_active = false
	obstacle_hit.emit()
	_check_best_score()
	_log_analytics_event("game_lose", {"score": score, "distance": distance_traveled})
	game_lost.emit()

func win_game() -> void:
	if not is_game_active:
		return
	is_game_active = false
	_check_best_score()
	_log_analytics_event("game_win", {"score": score, "distance": distance_traveled})
	game_won.emit()

func _log_analytics_event(event_name: String, params: Dictionary) -> void:
	# STUB — replace this with a real ad-network / analytics SDK call
	# (e.g. AppsFlyer, Facebook Ads SDK, playable-ad host bridge, etc.)
	# Keeping every event funneled through here means integration later
	# is a one-function change, not a project-wide search-and-replace.
	print("[ANALYTICS] %s %s" % [event_name, params])
