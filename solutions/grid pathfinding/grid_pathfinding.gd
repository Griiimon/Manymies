extends Pathfinder

@export var GRID_WIDTH: int= 40
@export var GRID_HEIGHT: int= 25

# path search can be expensive so we limit them to n per frame
@export var NUM_SEARCHES_PER_FRAME: int= 10


var flow_field: Dictionary

# cache the calculated direction to the next pathfinding cell in the path to the player
# for each grid tile
var cached_directions: Dictionary

# store the pathfinding cell position of the player for the last calculations, so we don't
# have to run them again if the player hasnt moved (much)
var previous_player_grid_coords= null


func _ready() -> void:
	super()


# with non_blocking set to true we run a poor-mans threaded version
func update(player_pos: Vector2, non_blocking: bool= false):
	# in non_blocking mode this function can take a lot of frames to finish and is
	# running in parallel, so we need to avoid running several update() concurrently
	if busy: 
		#print("Pathfinder busy")
		return
	
	var player_grid_coords: Vector2i= get_grid_coords(player_pos)

	if previous_player_grid_coords and previous_player_grid_coords == player_grid_coords:
		return

	previous_player_grid_coords= player_grid_coords

	busy= true

	flow_field.clear()
	
	var rect:= Rect2i(player_grid_coords - Vector2i(GRID_WIDTH, GRID_HEIGHT) / 2, Vector2i(GRID_WIDTH, GRID_HEIGHT))

	var active_points: Array[Vector2i]= []
	active_points.append(player_grid_coords)
	flow_field[player_grid_coords]= 0
	
	while not active_points.is_empty():
		var active_point: Vector2i= active_points[0]
		for x in range(-1, 2):
			for y in range(-1, 2):
				var point:= Vector2i(x, y)
				point+= player_grid_coords
				if not point in active_points and rect.has_point(point):
					if Global.obstacle_tile_map.get_cell_source_id(point) == -1:
						if not flow_field.has(point):
							active_points.append(point)
							flow_field[point]= flow_field[active_point] + 1
						else:
							flow_field[point]= min(flow_field[point], flow_field[active_point] + 1)
		
		active_points.remove_at(0)

	cached_directions.clear()

	for key: Vector2i in flow_field.keys():
		var lowest:= 99
		for x in range(-1, 2):
			for y in range(-1, 2):
				var neighbor: Vector2i= key + Vector2i(x, y)
				if flow_field.has(neighbor) and flow_field[neighbor] < lowest:
					lowest= flow_field[neighbor]
					cached_directions[key]= Vector2(neighbor - key).normalized()
		
		#if non_blocking and y % NUM_SEARCHES_PER_FRAME == 0:
			#await get_tree().process_frame

	#print("Pathfinder updated")
	busy= false

	if debug:
		queue_redraw()


func get_direction(from: Vector2)-> Vector2:
	var grid_coords: Vector2i= get_grid_coords(from)
	if not cached_directions.has(grid_coords):
		return Vector2.ZERO
	return cached_directions[grid_coords]


func get_grid_coords(pos: Vector2)-> Vector2i:
	return pos / Global.TILE_SIZE


func _draw():
	if not debug: return
	
	for key: Vector2i in cached_directions:
		var center:= Vector2(key * Global.TILE_SIZE) + Vector2.ONE * Global.TILE_SIZE / 2
		var dir: Vector2= get_direction(center)
		
		draw_circle(center, 5, Color.AQUA, true)
		draw_line(center, center + dir * 20, Color.AQUA, 2)
