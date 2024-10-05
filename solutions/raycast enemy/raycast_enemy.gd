class_name RaycastEnemy
extends BaseEnemy

@export var maximum_speed: float= 25.0

# skip n calculation frames
@export var skip_frames: int= 20

@export var ray_length: float= 25.0

# how many rays on each side. the total amount will be num_side_raycasts * 2 + 1
@export var num_side_raycasts: int= 1

# the spread between each ray
@export var raycast_angle: float= 45.0

@onready var head: Node2D = $Head

static var helper_initialized: bool= false

var velocity: Vector2

# offset the tick used for skip_frames by a random number so
# it's more evenly spread out 
var tick_offset: int

# the target of the center raycast
var center_marker: Marker2D



func _ready():
	tick_offset= randi() % 60

	# initialize the RaycastHelper once with following values
	if not helper_initialized:
		RaycastHelper.collide_with_areas= true
		RaycastHelper.collide_with_bodies= true
		RaycastHelper.collision_mask= Global.PLAYER_COLLISION_LAYER + Global.OBSTACLE_COLLISION_LAYER + Global.RAYCAST_ENEMY_COLLISION_LAYER
		helper_initialized= true


	# add markers to the head node, where the raycast target positions are supposed to be
	var marker:= Marker2D.new()
	marker.position= head.transform.x * ray_length
	head.add_child(marker)
	center_marker= marker

	var angle:= 0.0

	for i in num_side_raycasts:
		angle+= raycast_angle
		marker= Marker2D.new()
		marker.position= head.transform.x.rotated(deg_to_rad(angle)) * ray_length
		head.add_child(marker)

		marker= Marker2D.new()
		marker.position= head.transform.x.rotated(deg_to_rad(-angle)) * ray_length
		head.add_child(marker)



func _physics_process(delta: float) -> void:
	if ( Engine.get_physics_frames() + tick_offset ) % ( skip_frames + 1 ) == 0:
		# this code block will only run each n physics ticks
		# where n is defined in skip_frames 
		
		var target_pos: Vector2= Global.player.position
		if Global.pathfinder:
			target_pos= position + Global.pathfinder.get_direction(position)
		
		# smoothly rotate the head ( and raycast marker children ) towards the target position
		head.global_transform= head.global_transform.interpolate_with(head.global_transform.looking_at(target_pos), 0.5)

		# steering vector combines all non-colliding steering raycasts
		var steer_vec: Vector2= Vector2.ZERO
		var center_blocked:= false
		
		for marker: Marker2D in head.get_children():
			RaycastHelper.update(head.global_position, marker.global_position)
			if not RaycastHelper.is_colliding():
				steer_vec+= (marker.global_position - head.global_position).normalized()
			elif marker == center_marker:
				center_blocked= true

		steer_vec= steer_vec.normalized()
		
		# if the center ray was blocked but the steering vector is perfectly centered
		if center_blocked: 
			if steer_vec.is_equal_approx((center_marker.global_position - head.global_position).normalized()):
				# ..we shouldnt move
				steer_vec= Vector2.ZERO
				# ..but wiggle the head a little to maybe get a favorable angle the 
				# next time we steer to potentially slide around an obstacle
				head.rotate(randf_range(-0.3, 0.3))
				
					
		velocity= maximum_speed * steer_vec
	
	position+= velocity * delta
