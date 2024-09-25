extends Node2D


@export var pause_below_n_fps: int= 20
@onready var enemies: Node2D = $Enemies



func _ready() -> void:
	Global.enemies= enemies


func _process(delta: float) -> void:
	assert(Engine.get_process_frames() < 500 or Engine.get_frames_per_second() >= pause_below_n_fps, "Dropped to %d FPS with %d enemies" % [Engine.get_frames_per_second(), enemies.get_child_count()])
