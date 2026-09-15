extends Node2D
class_name LaneSpawner

## Drives the "world scrolls toward player" illusion AND the spawn logic.
##
## PERSPECTIVE: items spawn tiny at the horizon and interpolate toward
## their real lane x-position and full scale as they approach the player,
## giving the pseudo-3D converging-lanes look. Only the visual x/scale is
## perspective-interpolated — the actual gameplay collision still lines
## up with the player exactly the way it did before, because by the time
## an item reaches the player's y it has fully resolved to its real lane
## position and scale 1.0.
##
## SOLVABLE SPAWNING (unchanged from before): each wave fills at most
## (lane_count - 1) lanes with obstacles, so there is ALWAYS at least one
## clear lane. Difficulty ramps by increasing how many lanes get blocked
## as distance increases — never by blocking every lane.

@export var obstacle_scene: PackedScene = preload("res://scenes/obstacle.tscn")
@export var collectible_scene: PackedScene = preload("res://scenes/collectible.tscn")
@export var player_path: NodePath

var config: GameConfig
var player: Player
var lane_positions: Array[float] = []
var active_items: Array[Node2D] = []
var wave_timer: float = 0.0

var horizon_y: float = 0.0
var floor_y: float = 0.0
var vanishing_x: float = 0.0

func _ready() -> void:
	config = GameManager.config
	player = get_node(player_path)
	lane_positions = player.lane_positions
	var size: Vector2 = get_viewport_rect().size
	horizon_y = size.y * config.horizon_ratio
	floor_y = player.position.y
	vanishing_x = size.x / 2.0
	set_process(false)

func begin_spawning() -> void:
	active_items.clear()
	wave_timer = config.wave_interval * 1.2  # brief grace period before first wave
	set_process(true)

func stop_spawning() -> void:
	set_process(false)
	for item in active_items:
		if is_instance_valid(item):
			item.queue_free()
	active_items.clear()

func _process(delta: float) -> void:
	GameManager.advance(delta)
	_scroll_items(delta)
	wave_timer -= delta
	if wave_timer <= 0.0:
		wave_timer = config.wave_interval
		_spawn_wave()

func _scroll_items(delta: float) -> void:
	var despawn_y: float = get_viewport_rect().size.y + 150.0
	for i in range(active_items.size() - 1, -1, -1):
		var item := active_items[i]
		if not is_instance_valid(item):
			active_items.remove_at(i)
			continue

		item.position.y += GameManager.current_speed * delta

		var t: float = clampf((item.position.y - horizon_y) / max(1.0, floor_y - horizon_y), 0.0, 1.0)
		var lane_index: int = item.get_meta("lane_index")
		item.position.x = lerp(vanishing_x, lane_positions[lane_index], t)
		var s: float = lerp(config.item_min_scale, 1.0, t)
		item.scale = Vector2(s, s)

		if item.position.y > despawn_y:
			item.queue_free()
			active_items.remove_at(i)

func _spawn_wave() -> void:
	var lane_count: int = lane_positions.size()
	if lane_count <= 0:
		return

	# Difficulty ramps from 0 (run start) to 1 (near level_length).
	var difficulty: float = clampf(GameManager.distance_traveled / config.level_length, 0.0, 1.0)
	var max_obstacle_lanes: int = max(1, lane_count - 1)  # NEVER all lanes
	var obstacle_lane_count: int = clampi(
		1 + int(round(difficulty * (max_obstacle_lanes - 1))),
		1,
		max_obstacle_lanes
	)

	var lane_indices: Array[int] = []
	for i in range(lane_count):
		lane_indices.append(i)
	lane_indices.shuffle()

	var obstacle_lanes: Array[int] = lane_indices.slice(0, obstacle_lane_count)
	var open_lanes: Array[int] = lane_indices.slice(obstacle_lane_count)

	for lane in obstacle_lanes:
		_spawn_at(obstacle_scene, lane)

	for lane in open_lanes:
		if randf() < config.collectible_fill_chance:
			_spawn_at(collectible_scene, lane)

func _spawn_at(scene: PackedScene, lane_index: int) -> void:
	var instance := scene.instantiate() as Node2D
	instance.position = Vector2(vanishing_x, horizon_y)
	instance.scale = Vector2(config.item_min_scale, config.item_min_scale)
	instance.set_meta("lane_index", lane_index)
	add_child(instance)
	active_items.append(instance)
