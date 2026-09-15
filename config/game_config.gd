extends Resource
class_name GameConfig

## This is THE file a buyer edits to reskin gameplay feel AND appearance.
## Every number/color that affects difficulty, speed, scoring, or branding
## lives here. Edit default_config.tres in the Inspector instead of
## touching scripts.

@export_group("Lanes & Input")
@export var lane_count: int = 3
@export var lane_width: float = 220.0
@export var lane_switch_speed: float = 12.0   # higher = snappier lane change
@export var swipe_threshold: float = 40.0     # pixels of drag before a lane switch fires

@export_group("Speed & Difficulty")
@export var forward_speed: float = 500.0
@export var speed_increase_per_second: float = 12.0
@export var max_forward_speed: float = 1200.0

@export_group("Level")
@export var level_length: float = 8000.0      # distance (px) to reach the win screen
@export var checkpoint_interval: float = 2000.0

@export_group("Spawning")
@export var wave_interval: float = 1.1        # seconds between spawn waves
@export var collectible_fill_chance: float = 0.75  # chance an open lane gets a package
@export var spawn_y_position: float = -100.0  # legacy/unused now items spawn at the horizon

@export_group("Perspective")
@export var horizon_ratio: float = 0.42       # screen-height fraction where the horizon sits
@export var item_min_scale: float = 0.18      # how tiny objects are right at the horizon

@export_group("Scoring")
@export var collectible_value: int = 10
@export var combo_multiplier_step: float = 0.5
@export var combo_max_multiplier: float = 4.0
@export var combo_reset_time: float = 2.0

@export_group("Branding / CTA")
@export var game_title: String = "Swipe Rush"
@export var intro_headline: String = "DELIVER THE PACKAGE!"
@export var cta_text: String = "Play Now!"
@export var win_message: String = "You Made It!"
@export var lose_message: String = "Try Again!"
@export var swipe_hint_text: String = "SWIPE TO MOVE"
@export var best_score_label: String = "Best"

@export_group("Visual Colors (Reskin Here)")
@export var player_color: Color = Color(0.95, 0.55, 0.15)
@export var player_accent_color: Color = Color(0.85, 0.2, 0.2)
@export var package_color: Color = Color(0.65, 0.45, 0.25)
@export var package_tape_color: Color = Color(0.9, 0.85, 0.7)
@export var hazard_color: Color = Color(0.35, 0.38, 0.42)
@export var hazard_stripe_color: Color = Color(1.0, 0.75, 0.1)
@export var sky_color_top: Color = Color(0.42, 0.62, 0.92)
@export var sky_color_bottom: Color = Color(0.78, 0.85, 0.95)
@export var rooftop_color_a: Color = Color(0.55, 0.53, 0.58)
@export var rooftop_color_b: Color = Color(0.5, 0.48, 0.53)
@export var skyline_color: Color = Color(0.32, 0.34, 0.42)
@export var lane_marking_color: Color = Color(1, 1, 1, 0.35)
