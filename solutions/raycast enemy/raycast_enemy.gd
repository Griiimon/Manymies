class_name RaycastEnemy
extends BaseEnemy

@export var maximum_speed: float= 25.0

# skip n calculation frames
@export var skip_frames: int= 20

# for smoother movement
@export_range(0.0, 1.0) var jitter_fix= 0.5

@export var ray_length: float= 25.0
@export var num_side_raycasts: int= 1
@export var raycast_angle: float= 45.0

@onready var head: Node2D = $Head

static var helper_initialized: bool= false

var velocity: Vector2
var tick_offset: int
var center_marker: Marker2D



func _ready():
	tick_offset= randi() % 60

	if not helper_initialized:
		RaycastHelper.collide_with_areas= true
		RaycastHelper.collide_with_bodies= true
		RaycastHelper.collision_mask= Global.PLAYER_COLLISION_LAYER + Global.OBSTACLE_COLLISION_LAYER + Global.RAYCAST_ENEMY_COLLISION_LAYER
		helper_initialized= true


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
		
		# apply jitter fix for smoother movement
		velocity= velocity.lerp(Vector2.ZERO, 1.0 - jitter_fix)
		
		var target_pos: Vector2= Global.player.position
		head.global_transform= head.global_transform.interpolate_with(head.global_transform.looking_at(target_pos), 0.5)
		
		var steer_vec: Vector2= Vector2.ZERO
		var center_blocked:= false
		
		for marker: Marker2D in head.get_children():
			RaycastHelper.update(head.global_position, marker.global_position)
			if not RaycastHelper.is_colliding():
				steer_vec+= (marker.global_position - head.global_position).normalized()
			elif marker == center_marker:
				center_blocked= true

		steer_vec= steer_vec.normalized()
		
		#if center_blocked: 
			#if steer_vec.is_equal_approx(straight_raycast.target_position.rotated(straight_raycast.global_rotation).normalized()):
				#steer_vec= Vector2.ZERO
				#rotate(randf_range(-0.1, 0.1))
					
		velocity= maximum_speed * steer_vec
	
	position+= velocity * delta
