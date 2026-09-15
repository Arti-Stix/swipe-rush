extends Node2D

@onready var camera: ShakeCamera = $Camera2D
@onready var spawner: LaneSpawner = $LaneSpawner

@onready var score_label: Label = $UI/HUD/ScoreLabel
@onready var combo_label: Label = $UI/HUD/ComboLabel
@onready var progress_bar: ProgressBar = $UI/HUD/DistanceBar

@onready var start_panel: Control = $UI/StartPanel
@onready var brand_label: Label = $UI/StartPanel/BrandLabel
@onready var title_label: Label = $UI/StartPanel/TitleLabel
@onready var subtitle_label: Label = $UI/StartPanel/SubtitleLabel
@onready var start_button: Button = $UI/StartPanel/StartButton

@onready var win_panel: Control = $UI/WinPanel
@onready var win_result_label: Label = $UI/WinPanel/ResultLabel
@onready var win_score_label: Label = $UI/WinPanel/FinalScoreLabel
@onready var win_best_label: Label = $UI/WinPanel/BestScoreLabel
@onready var cta_button: Button = $UI/WinPanel/CTAButton

@onready var lose_panel: Control = $UI/LosePanel
@onready var lose_result_label: Label = $UI/LosePanel/ResultLabel
@onready var lose_best_label: Label = $UI/LosePanel/BestScoreLabel
@onready var restart_button: Button = $UI/LosePanel/RestartButton

@onready var delivery_anim: Control = $UI/DeliveryAnim
@onready var package_icon: ColorRect = $UI/DeliveryAnim/PackageIcon
@onready var door_icon: ColorRect = $UI/DeliveryAnim/DoorIcon

var package_icon_start_pos: Vector2

func _ready() -> void:
	brand_label.text = GameManager.config.game_title
	title_label.text = GameManager.config.intro_headline
	subtitle_label.text = GameManager.config.swipe_hint_text
	cta_button.text = GameManager.config.cta_text
	win_result_label.text = GameManager.config.win_message
	lose_result_label.text = GameManager.config.lose_message

	package_icon_start_pos = package_icon.position

	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	cta_button.pressed.connect(_on_cta_pressed)

	GameManager.score_changed.connect(_on_score_changed)
	GameManager.combo_changed.connect(_on_combo_changed)
	GameManager.distance_changed.connect(_on_distance_changed)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	GameManager.obstacle_hit.connect(_on_obstacle_hit)

	win_panel.visible = false
	lose_panel.visible = false
	delivery_anim.visible = false
	start_panel.visible = true
	progress_bar.max_value = GameManager.config.level_length

func _on_start_pressed() -> void:
	start_panel.visible = false
	GameManager.start_game()
	spawner.begin_spawning()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_cta_pressed() -> void:
	# STUB: this is where a real playable ad would call the ad network's
	# "click to install / open store" bridge function.
	print("[CTA] Store/redirect link would open here.")

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
	win_score_label.text = "Score: %d" % new_score

func _on_combo_changed(multiplier: float) -> void:
	combo_label.text = "x%.1f" % multiplier
	combo_label.visible = multiplier > 1.0

func _on_distance_changed(distance: float, total: float) -> void:
	progress_bar.value = distance

func _on_obstacle_hit() -> void:
	camera.shake(8.0)

func _on_game_won() -> void:
	spawner.stop_spawning()
	_update_best_labels()
	await _play_delivery_transition()
	_show_panel_animated(win_panel)

func _on_game_lost() -> void:
	spawner.stop_spawning()
	_update_best_labels()
	# Brief pause so the shake/impact reads before the result panel arrives.
	await get_tree().create_timer(0.15).timeout
	_show_panel_animated(lose_panel)

func _update_best_labels() -> void:
	var text: String = "%s: %d" % [GameManager.config.best_score_label, GameManager.best_score]
	win_best_label.text = text
	lose_best_label.text = text

func _play_delivery_transition() -> void:
	delivery_anim.visible = true
	package_icon.position = package_icon_start_pos
	package_icon.scale = Vector2.ONE
	var tween := create_tween()
	tween.tween_property(package_icon, "position", door_icon.position, 0.45) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(package_icon, "scale", Vector2(0.3, 0.3), 0.45)
	await tween.finished
	delivery_anim.visible = false

func _show_panel_animated(panel: Control) -> void:
	panel.visible = true
	panel.pivot_offset = panel.size / 2.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.85, 0.85)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.35)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
