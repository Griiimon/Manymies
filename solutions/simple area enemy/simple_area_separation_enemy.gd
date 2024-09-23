class_name SimpleAreaSeparationEnemy
extends BaseEnemy


# if enabled this will dynamically trigger an intersect_shape()
# query instead of using the Separation Area node
@export var dynamic_separation_area: bool= false

# importance of target direction for final velocity
@export var target_weight: float= 10.0
# importance of separation from neighboring enemies for final velocity
@export var separation_weight: float= 1.0
@export var separation_radius: float= 25.0
# weight that forces enemies to steer away from the player the closer they get
@export var player_separation_weight: float= 1000.0

@export var maximum_speed: float= 10.0
# skip n calculation frames
@export var skip_frames: int= 0
# fine-tune the intersect_shape() max_results
@export var max_intersect_results:= 32
# for smoother movement
@export_range(0.0, 1.0) var jitter_fix= 0.5

@onready var separation_area: Area2D = $"Separation Area"
@onready var separation_collision_shape: CollisionShape2D = $"Separation Area/CollisionShape2D"

var velocity: Vector2
var circle_shape: CircleShape2D
var query: PhysicsShapeQueryParameters2D
# offset the tick used for skip_frames by a random number so
# it's more evenly spread out 
var tick_offset: int



func _ready() -> void:
	if dynamic_separation_area:
		circle_shape= separation_collision_shape.shape
		separation_area.queue_free()
		
		query= PhysicsShapeQueryParameters2D.new()
		query.collide_with_bodies= false
		query.collide_with_areas= true
		query.collision_mask= 2
		query.shape= circle_shape
		query.exclude= [(get_node(".") as Area2D).get_rid()]
		query.transform= Transform2D.IDENTITY

	else:
		assert(separation_collision_shape.shape is CircleShape2D)
		(separation_collision_shape.shape as CircleShape2D).radius= separation_radius

	tick_offset= randi() % 60


func _physics_process(delta: float) -> void:
	if ( Engine.get_physics_frames() + tick_offset ) % ( skip_frames + 1 ) == 0:
		# velocity= Vector2.ZERO
		velocity= velocity.lerp(Vector2.ZERO, 1.0 - jitter_fix)
		
		for other_pos in get_overlapping_area_positions():
			separate_from(other_pos, separation_weight)
		
		separate_from(Global.player.position, player_separation_weight)

		var target_dir: Vector2= (Global.player.position - position).normalized()
		velocity+= target_dir * target_weight

		velocity= velocity.normalized() * maximum_speed

	position+= velocity * delta


func get_overlapping_area_positions()-> Array[Vector2]:
	var result: Array[Vector2]= []
	
	if dynamic_separation_area:
		query.transform.origin= position
		var query_result= get_world_2d().direct_space_state.intersect_shape(query, max_intersect_results)
		if query_result:
			for item in query_result:
				result.append(item.collider.position)
	else:
		for area in separation_area.get_overlapping_areas():
			result.append(area.position)
	
	return result


func separate_from(other_pos: Vector2, weight: float):
	var vec: Vector2= position - other_pos
	if vec.is_zero_approx(): return
	velocity+= vec.normalized() * 1.0 / vec.length() * weight
