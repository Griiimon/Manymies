extends Pathfinder

@export var tile_map: TileMapLayer
@export var dynamic_field_size: Vector2i= Vector2i(60, 40)

# with strict mode enabled always follow the flowfield direction..
@export var strict_mode: bool= true

# .. otherwise go straight to the player unless the flowfields direction
# deviation from the direction to the player is greater than this angle
@export var max_deviation_angle: float= 30.0

@export var debug_mode: bool= false
@export var disable_waypoints: bool= false

@onready var max_deviation_angle_cos: float= cos(deg_to_rad(max_deviation_angle))

var dynamic_flow_field: DirectionFlowField
var static_flow_fields: Array[DirectionFlowField]
var closest_waypoint_flow_field: DirectionFlowField

var previous_player_grid_coords= null



func _ready():
	assert(tile_map, "Assign a Tile Map Layer to this Pathfinder")
	super()
	
	dynamic_flow_field= DirectionFlowField.new(tile_map, dynamic_field_size)
	
	if not disable_waypoints:
		for marker: Marker2D in find_children("*", "Marker2D"):
			var grid_coords: Vector2i= get_grid_coords(marker.global_position)
			var static_flow_field:= DirectionFlowField.new(tile_map)
			static_flow_field.build(grid_coords)
			static_flow_fields.append(static_flow_field)
			print("Created Static FlowField #", static_flow_fields.size(), " @", grid_coords)

		#var rect: Rect2i
		#for key in static_flow_field.field:
			#rect= rect.expand(key)
		
		#assert(rect == tile_map.get_used_rect(), str(tile_map.get_used_rect()))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		queue_redraw()


func get_grid_coords(pos: Vector2)-> Vector2i:
	return tile_map.local_to_map(pos)


func get_direction(from: Vector2)-> Vector2:
	var dir: Vector2= get_flowfield_direction(from)
	
	if not Global.pathfinder.strict_mode:
		var player_dir: Vector2= from.direction_to(Global.player.position)
		if player_dir.dot(dir) > max_deviation_angle_cos:
			dir= player_dir
	
	return dir


func get_flowfield_direction(from: Vector2)-> Vector2:
	if dynamic_flow_field.rect.has_point(get_grid_coords(from)):
		return dynamic_flow_field.get_direction(from)

	var player_grid_coords: Vector2i= get_grid_coords(Global.player.position)

	if not closest_waypoint_flow_field:
		return Vector2.ZERO

	return closest_waypoint_flow_field.get_direction(from)


func update(player_pos: Vector2, non_blocking: bool= true):
	if busy: return
	
	var player_grid_coords: Vector2i= get_grid_coords(player_pos)

	if previous_player_grid_coords and previous_player_grid_coords == player_grid_coords:
		return

	previous_player_grid_coords= player_grid_coords
	
	dynamic_flow_field.build(player_grid_coords)

	closest_waypoint_flow_field= null
	var lowest_distance: float
	
	for field in static_flow_fields:
		var new_distance: float= field.origin.distance_to(player_grid_coords)
		if not closest_waypoint_flow_field or new_distance < lowest_distance:
			closest_waypoint_flow_field= field
			lowest_distance= new_distance


func _draw():
	if not debug_mode: return
	if not is_inside_tree() or not Global.player: return
	
	busy= true
	
	if not disable_waypoints:
		closest_waypoint_flow_field.debug_draw(self, tile_map, Color.BLUE_VIOLET)

	dynamic_flow_field.debug_draw(self, tile_map, Color.RED)
	
	if not disable_waypoints:
		for flow_field in static_flow_fields:
			var global_pos: Vector2= tile_map.map_to_local(flow_field.origin)
			var color: Color= Color.GREEN if flow_field == closest_waypoint_flow_field else Color.YELLOW
			draw_circle(global_pos, Global.TILE_SIZE, color, false, 5)

			if flow_field == closest_waypoint_flow_field:
				draw_line(global_pos, Global.player.position, Color.ORANGE, 3)

	busy= false
