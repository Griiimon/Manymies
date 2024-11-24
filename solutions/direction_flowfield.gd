class_name DirectionFlowField
extends FlowField

var cached_directions: Dictionary



func build(_origin: Vector2i):
	super(_origin)

	cached_directions.clear()
	
	for key: Vector2i in field.keys():
		# find the lowest valued neighbor to each flow field point and set it as the
		# preferred direction from there 
		var lowest:= 999999.9
		for x in range(-1, 2):
			for y in range(-1, 2):
				if x == 0 or y == 0 or allow_diagonals:
					var neighbor: Vector2i= key + Vector2i(x, y)
					if field.has(neighbor) and field[neighbor] < lowest:
						lowest= field[neighbor]
						cached_directions[key]= Vector2(neighbor - key).normalized()


func get_direction(from: Vector2)-> Vector2:
	var grid_coords: Vector2i= get_grid_coords(from)
	if not cached_directions.has(grid_coords):
		return Vector2.ZERO
	return cached_directions[grid_coords]


func debug_draw(canvas: CanvasItem, tile_map: TileMapLayer, color: Color):
	for key: Vector2i in cached_directions:
		var center:= tile_map.map_to_local(key)
		var dir: Vector2= get_direction(center)
			
		canvas.draw_circle(center, 5, color, true)
		canvas.draw_line(center, center + dir * 20, color, 2)

	#super(canvas, tile_map, color)
