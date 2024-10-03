extends Pathfinder

@export var GRID_SIZE: int= 65

var astar_grid: AStarGrid2D
var cached_directions: Dictionary



func _ready() -> void:
	super()
	astar_grid= AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, GRID_SIZE, GRID_SIZE)
	astar_grid.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)

	#astar_grid.update()


func update(player_pos: Vector2, non_blocking: bool= true):
	if busy: 
		print("Pathfinder busy")
		return
	
	busy= true
	
	var player_grid_coords: Vector2i= get_grid_coords(player_pos)

	# TODO remember last player grid pos and if its the same dont run


	var timer:= Stopwatch.new()
	astar_grid.update()
	
	for x in GRID_SIZE:
		for y in GRID_SIZE:
			var grid_coords:= Vector2i(x, y)
			if Global.obstacle_tile_map.get_cell_source_id(grid_coords) != -1:
				astar_grid.set_point_solid(grid_coords)

	timer.stop("Pathfinder points update")
	
	for x in GRID_SIZE:
		for y in GRID_SIZE:
			var grid_coords:= Vector2i(x, y)
			var path: PackedVector2Array= astar_grid.get_point_path(grid_coords, player_grid_coords)
			
			var direction: Vector2
			if path.size() < 2:
				direction= Vector2.ZERO
			else:
				direction= Vector2(path[1] - path[0]).normalized()
			
			cached_directions[grid_coords]= direction
			if non_blocking and y % 10 == 0:
				await get_tree().process_frame

	print("Pathfinder updated")
	busy= false


func get_direction(from: Vector2)-> Vector2:
	var grid_coords: Vector2i= get_grid_coords(from)
	if not cached_directions.has(grid_coords):
		return Vector2.ZERO
	return cached_directions[grid_coords]


func get_grid_coords(pos: Vector2)-> Vector2i:
	return pos / Global.TILE_SIZE
