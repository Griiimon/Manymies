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
		for neighbor_type in [ TileSet.CELL_NEIGHBOR_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE, TileSet.CELL_NEIGHBOR_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_CORNER, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE ]:
			var neighbor: Vector2i= tile_map.get_neighbor_cell(key, neighbor_type)
			if field.has(neighbor) and field[neighbor] < lowest:
				lowest= field[neighbor]
				#cached_directions[key]= Vector2(neighbor - key).normalized()
				cached_directions[key]= Vector2(Global.pathfinder.tile_map.map_to_local(neighbor) - Global.pathfinder.tile_map.map_to_local(key)).normalized()


func get_direction(from: Vector2)-> Vector2:
	var grid_coords: Vector2i= get_grid_coords(from)
	if not cached_directions.has(grid_coords):
		return Vector2.ZERO
	return cached_directions[grid_coords]


func debug_draw(canvas: CanvasItem, tile_map: TileMapLayer, color: Color):
	var color_a= color
	color_a.a= 0.5
	for key: Vector2i in cached_directions:
		var center:= tile_map.map_to_local(key)
		var dir: Vector2= get_direction(center)
			
		canvas.draw_circle(center, 5, color_a, true)
		canvas.draw_line(center, center + dir * 20, color_a, 2)

	#super(canvas, tile_map, color)
