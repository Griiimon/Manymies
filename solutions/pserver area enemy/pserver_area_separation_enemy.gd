class_name PServerSeparationEnemy
extends BaseEnemy

# PServer Separation Enemy creates the Area directly on the 
# PhysicsServer and has a plain Node2D as root node

# PERFORMS WAY WORSE than the Area-Node solution
# potentially not setting it up correctly?


# if enabled this will dynamically trigger an intersect_shape()
# query instead of using the Separation Area node
@export var dynamic_separation_area: bool= false

# importance of target direction for final velocity
@export var target_weight: float= 10.0
# importance of separation from neighboring enemies for final velocity
@export var separation_weight: float= 1.0
@export var separation_radius: float= 25.0

@export var maximum_speed: float= 10.0
# skip n calculation frames
@export var skip_frames: int= 0
# for smoother movement
@export_range(0.0, 1.0) var jitter_fix= 0.5

@onready var separation_area: Area2D = $"Separation Area"
@onready var separation_collision_shape: CollisionShape2D = $"Separation Area/CollisionShape2D"

var velocity: Vector2
var circle_shape: CircleShape2D
var query: PhysicsShapeQueryParameters2D
var rid: RID


func _ready() -> void:
	rid= PhysicsServer2D.area_create()
	PhysicsServer2D.area_set_collision_layer(rid, 2)
	PhysicsServer2D.area_set_collision_mask(rid, 0)
	PhysicsServer2D.area_set_monitorable(rid, true)
	
	var shape_rid= PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, $CollisionShape2D.shape.radius)
	$CollisionShape2D.queue_free()
	PhysicsServer2D.area_add_shape(rid, shape_rid)
	
	PhysicsServer2D.area_set_space(rid, get_world_2d().space)
	
	if dynamic_separation_area:
		circle_shape= separation_collision_shape.shape
		separation_area.queue_free()
		
		query= PhysicsShapeQueryParameters2D.new()
		query.collide_with_bodies= false
		query.collide_with_areas= true
		query.collision_mask= 2
		query.shape= circle_shape
		query.exclude= [rid]
		query.transform= Transform2D.IDENTITY

	else:
		assert(separation_collision_shape.shape is CircleShape2D)
		(separation_collision_shape.shape as CircleShape2D).radius= separation_radius


func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % ( skip_frames + 1 ) == 0:
		# velocity= Vector2.ZERO
		velocity= velocity.lerp(Vector2.ZERO, 1.0 - jitter_fix)
		
		for other_pos in get_overlapping_area_positions():
			separate_from(other_pos)

		var target_dir: Vector2= (Global.player.position - position).normalized()
		velocity+= target_dir * target_weight

		velocity= velocity.normalized() * maximum_speed

	position+= velocity * delta
	PhysicsServer2D.area_set_transform(rid, transform)


func get_overlapping_area_positions()-> Array[Vector2]:
	var result: Array[Vector2]= []
	
	if dynamic_separation_area:
		query.transform.origin= position
		var query_result= get_world_2d().direct_space_state.intersect_shape(query)
		if query_result:
			for item in query_result:
				result.append(PhysicsServer2D.area_get_transform(item.rid).origin)
	else:
		for area in separation_area.get_overlapping_areas():
			result.append(area.position)
	
	return result


func separate_from(other_pos: Vector2):
	var vec: Vector2= position - other_pos
	if vec.is_zero_approx(): return
	velocity+= vec.normalized() * 1.0 / vec.length() * separation_weight
