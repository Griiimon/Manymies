extends Pathfinder

@export var tile_map: TileMapLayer
@export var dynamic_field_size: Vector2i= Vector2i(60, 40)

var dynamic_flow_field: DirectionFlowField
var static_flow_fields: Array[DirectionFlowField]

var previous_player_grid_coords= null



func _ready():
	assert(tile_map, "Assign a Tile Map Layer to this Pathfinder")
	super()
	
	dynamic_flow_field= DirectionFlowField.new(tile_map, dynamic_field_size)
	
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


func get_direction(from: Vector2)-> Vector2:
	if dynamic_flow_field.rect.has_point(get_grid_coords(from)):
		return dynamic_flow_field.get_direction(from)

	var player_grid_coords: Vector2i= get_grid_coords(Global.player.position)

	var best_flow_field: DirectionFlowField
	var lowest_distance: float
	
	for field in static_flow_fields:
		var new_distance: float= field.origin.distance_to(player_grid_coords)
		if not best_flow_field or new_distance < lowest_distance:
			best_flow_field= field
			lowest_distance= new_distance

	if not best_flow_field:
		return Vector2.ZERO

	#prints("Chose FlowField", best_flow_field.origin, "for player coords", player_grid_coords)

	return best_flow_field.get_direction(from)


func update(player_pos: Vector2, non_blocking: bool= true):
	var player_grid_coords: Vector2i= get_grid_coords(player_pos)

	if previous_player_grid_coords and previous_player_grid_coords == player_grid_coords:
		return

	previous_player_grid_coords= player_grid_coords
	
	dynamic_flow_field.build(player_grid_coords)
