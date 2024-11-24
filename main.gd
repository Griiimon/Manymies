extends Node2D


@export var pause_below_n_fps: int= 20

@onready var enemies: Node2D = $Enemies
@onready var player: Player = $Player



func _ready() -> void:
	Global.enemies= enemies
	Global.obstacle_tile_map= $"TileMapLayer Obstacles"
	var dummy_label: Label= get_node_or_null("Dummy")
	if dummy_label:
		Global.font= dummy_label.get_theme_default_font()
	update_pathfinder(false)


func _process(delta: float) -> void:
	assert(Engine.get_process_frames() < 500 or Engine.get_frames_per_second() >= pause_below_n_fps, "Dropped to %d FPS with %d enemies" % [Engine.get_frames_per_second(), enemies.get_child_count()])


func update_pathfinder(non_blocking: bool= true):
	if Global.pathfinder:
		Global.pathfinder.update(player.position, non_blocking)
