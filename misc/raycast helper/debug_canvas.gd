extends Node2D

var debug_lines: Array[DebugLine]



func _physics_process(delta):
	queue_redraw()


func _draw():
	for line in debug_lines:
		draw_line(line.from, line.to, Color.RED if line.colliding else Color.DODGER_BLUE)
	debug_lines.clear()
