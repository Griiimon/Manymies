extends RayCast2D

@export var debug_mode: bool= false

@onready var debug_canvas = $"CanvasLayer/Debug Canvas"



func update(from: Vector2, to: Vector2):
	transform.origin= from
	target_position= to_local(to)
	force_raycast_update()
	if debug_mode:
		debug_canvas.debug_lines.append(DebugLine.new(from, to, is_colliding()))
