class_name FlowField

const allow_diagonals:= true

var field: Dictionary

var tile_map: TileMapLayer
var origin: Vector2i
var size: Vector2i
var rect: Rect2i



func _init(_tile_map: TileMapLayer, _size: Vector2i= Vector2i.ZERO):
	tile_map= _tile_map
	size= _size


func build(_origin: Vector2i):
	origin= _origin

	field.clear()
	
	if size:
		rect= Rect2i(origin - Vector2i(size.x, size.y) / 2, Vector2i(size.x, size.y))
	else:
		rect= tile_map.get_used_rect()

	# start the flow field from the origin with a value of 0
	var active_points: Array[Vector2i]= []
	active_points.append(origin)
	field[origin]= 0.0
	
	while not active_points.is_empty():
		# for each active point add all neighbor grid positions to the active points list,
		# that are inside the rect, arent part of the flow field yet and arent an obstacle
		
		var active_point: Vector2i= active_points[0]
		for x in range(-1, 2):
			for y in range(-1, 2):
				if x == 0 and y == 0: continue
				if x == 0 or y == 0 or allow_diagonals:
					var point:= Vector2i(x, y)
					point+= active_points[0]
					if rect.has_point(point):
						if tile_map.get_cell_source_id(point) == -1:
							if not field.has(point):
								active_points.append(point)
								# the new point has a value of the current point + 1
								field[point]= field[active_point] + sqrt(abs(x) + abs(y))
							else:
								# if this point is already part of the flow field choose
								# the lowest value
								field[point]= min(field[point], field[active_point] + sqrt(abs(x) + abs(y)))
								
		# remove this point from the active points list
		active_points.remove_at(0)

	#if debug:
		#queue_redraw()


func get_grid_coords(pos: Vector2)-> Vector2i:
	return Global.pathfinder.get_grid_coords(pos)


func debug_draw(canvas: CanvasItem, tile_map: TileMapLayer, color: Color):
	for key: Vector2i in field:
		var center:= tile_map.map_to_local(key)
		canvas.draw_string(Global.font, center, "%.1f" % field[key], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, color)
