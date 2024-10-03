extends Pathfinder

@export var GRID_WIDTH: int= 40
@export var GRID_HEIGHT: int= 25

# path search can be expensive so we limit them to n per frame
@export var NUM_SEARCHES_PER_FRAME: int= 10

var astar_grid: AStarGrid2D

# cache the calculated direction to the next pathfinding cell in the path to the player
# for each grid tile
var cached_directions: Dictionary

# store the pathfinding cell position of the player for the last calculations, so we don't
# have to run them again if the player hasnt moved (much)
var previous_player_grid_coords= null


func _ready() -> void:
	super()
	astar_grid= AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	astar_grid.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)


# with non_blocking set to true we run a poor-mans threaded version
func update(player_pos: Vector2, non_blocking: bool= true):
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

	astar_grid.update()
	
	# query all solid tiles from the tilemap
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var grid_coords:= Vector2i(x, y)
			if Global.obstacle_tile_map.get_cell_source_id(grid_coords) != -1:
				astar_grid.set_point_solid(grid_coords)
	
	# calculate the path from each cell to the player
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var grid_coords:= Vector2i(x, y)
			var path: PackedVector2Array= astar_grid.get_point_path(grid_coords, player_grid_coords)
			
			var direction: Vector2
			# if the path doesnt have at least 2 points we cant determine a direction to move in
			if path.size() < 2:
				direction= Vector2.ZERO
			else:
				# ..otherwise the direction is from waypoint #0 to waypoint #1
				direction= Vector2(path[1] - path[0]).normalized()
			
			cached_directions[grid_coords]= direction
			
			# wait for a frame after every n frames in non_blocking mode
			# so this update function doesnt stall the main thread
			if non_blocking and y % NUM_SEARCHES_PER_FRAME == 0:
				await get_tree().process_frame

	#print("Pathfinder updated")
	busy= false


func get_direction(from: Vector2)-> Vector2:
	var grid_coords: Vector2i= get_grid_coords(from)
	if not cached_directions.has(grid_coords):
		return Vector2.ZERO
	return cached_directions[grid_coords]


func get_grid_coords(pos: Vector2)-> Vector2i:
	return pos / Global.TILE_SIZE
