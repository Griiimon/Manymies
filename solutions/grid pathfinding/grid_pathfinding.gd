extends Pathfinder

@export var tile_map: TileMapLayer
@export var field_size: Vector2i= Vector2i(40, 25)

# with strict mode enabled always follow the flowfield direction..
@export var strict_mode: bool= true

# .. otherwise go straight to the player unless the flowfields direction
# deviation from the direction to the player is greater than this angle
@export var max_deviation_angle: float= 30.0

@export var debug_mode: bool= false

@onready var max_deviation_angle_cos: float= cos(deg_to_rad(max_deviation_angle))

var flow_field: DirectionFlowField

var previous_player_grid_coords= null



func _ready():
	assert(tile_map, "Assign a Tile Map Layer to this Pathfinder")
	super()
	
	flow_field= DirectionFlowField.new(tile_map, field_size)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		queue_redraw()


func get_direction(from: Vector2)-> Vector2:
	var dir: Vector2= get_flowfield_direction(from)
	
	if not Global.pathfinder.strict_mode or not dir:
		var player_dir: Vector2= from.direction_to(Global.player.position)
		if not dir or player_dir.dot(dir) > max_deviation_angle_cos:
			dir= player_dir
	
	return dir


func get_flowfield_direction(from: Vector2)-> Vector2:
	if flow_field.rect.has_point(get_grid_coords(from)):
		return flow_field.get_direction(from)
	return Vector2.ZERO


func update(player_pos: Vector2, non_blocking: bool= true):
	if busy: return
	
	var player_grid_coords: Vector2i= get_grid_coords(player_pos)

	if previous_player_grid_coords and previous_player_grid_coords == player_grid_coords:
		return

	previous_player_grid_coords= player_grid_coords
	
	flow_field.build(player_grid_coords)


func _draw():
	if not debug_mode: return
	if not is_inside_tree() or not Global.player: return
	
	busy= true
	
	flow_field.debug_draw(self, tile_map, Color.RED)

	busy= false








#
#extends Pathfinder
#
#@export var GRID_WIDTH: int= 40
#@export var GRID_HEIGHT: int= 25
#@export var allow_diagonals: bool= false
#
#var flow_field: Dictionary
#
## cache the calculated direction to the next pathfinding cell in the path to the player
## for each grid tile
#var cached_directions: Dictionary
#
## store the pathfinding cell position of the player for the last calculations, so we don't
## have to run them again if the player hasnt moved (much)
#var previous_player_grid_coords= null
#
#
#func _ready() -> void:
	#super()
#
#
#func update(player_pos: Vector2, non_blocking: bool= false):
	#var player_grid_coords: Vector2i= get_grid_coords(player_pos)
#
	#if previous_player_grid_coords and previous_player_grid_coords == player_grid_coords:
		#return
#
	#previous_player_grid_coords= player_grid_coords
#
#
	#flow_field.clear()
	#
	#var rect:= Rect2i(player_grid_coords - Vector2i(GRID_WIDTH, GRID_HEIGHT) / 2, Vector2i(GRID_WIDTH, GRID_HEIGHT))
#
	## start the flow field from the players grid coords with a value of 0
	#var active_points: Array[Vector2i]= []
	#active_points.append(player_grid_coords)
	#flow_field[player_grid_coords]= 0
	#
	#while not active_points.is_empty():
		## for each active point add all neighbor grid positions to the active points list,
		## that are inside the rect, arent part of the flow field yet and arent an obstacle
		#
		#var active_point: Vector2i= active_points[0]
		#for x in range(-1, 2):
			#for y in range(-1, 2):
				#if x == 0 or y == 0 or allow_diagonals:
					#var point:= Vector2i(x, y)
					#point+= active_points[0]
					#if not point in active_points and rect.has_point(point):
						#if Global.obstacle_tile_map.get_cell_source_id(point) == -1:
							#if not flow_field.has(point):
								#active_points.append(point)
								## the new point has a value of the current point + 1
								#flow_field[point]= flow_field[active_point] + 1
							#else:
								## if this point is already part of the flow field choose
								## the lowest value
								#flow_field[point]= min(flow_field[point], flow_field[active_point] + 1)
			#
		## remove this point from the active points list
		#active_points.remove_at(0)
#
	#cached_directions.clear()
#
	#for key: Vector2i in flow_field.keys():
		## find the lowest valued neighbor to each flow field point and set it as the
		## preferred direction from there 
		#var lowest:= 99
		#for x in range(-1, 2):
			#for y in range(-1, 2):
				#if x == 0 or y == 0 or allow_diagonals:
					#var neighbor: Vector2i= key + Vector2i(x, y)
					#if flow_field.has(neighbor) and flow_field[neighbor] < lowest:
						#lowest= flow_field[neighbor]
						#cached_directions[key]= Vector2(neighbor - key).normalized()
#
	#if debug:
		#queue_redraw()
#
#
#func get_direction(from: Vector2)-> Vector2:
	#var grid_coords: Vector2i= get_grid_coords(from)
	#if not cached_directions.has(grid_coords):
		#return Vector2.ZERO
	#return cached_directions[grid_coords]
#
#
#func get_grid_coords(pos: Vector2)-> Vector2i:
	#return pos / Global.TILE_SIZE
#
#
#func _draw():
	#if not debug: return
	#
	#for key: Vector2i in cached_directions:
		#var center:= Vector2(key * Global.TILE_SIZE) + Vector2.ONE * Global.TILE_SIZE / 2
		#var dir: Vector2= get_direction(center)
		#
		#draw_circle(center, 5, Color.AQUA, true)
		#draw_line(center, center + dir * 20, Color.AQUA, 2)
