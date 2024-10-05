class_name RaycastEnemy
extends BaseEnemy

@export var maximum_speed: float= 25.0

# skip n calculation frames
@export var skip_frames: int= 20

# for smoother movement
@export_range(0.0, 1.0) var jitter_fix= 0.5

@export var num_side_raycasts: int= 1

@export var raycast_angle: float= 45.0

@onready var head: Node2D = $Head
@onready var straight_raycast: RayCast2D = %"RayCast2D Straight"

var velocity: Vector2
var tick_offset: int


func _ready():
	tick_offset= randi() % 60

	var angle:= 0.0
	for i in num_side_raycasts:
		angle+= raycast_angle
		var new_raycast: RayCast2D= straight_raycast.duplicate()
		new_raycast.target_position= new_raycast.target_position.rotated(deg_to_rad(angle))
		head.add_child(new_raycast)

		new_raycast= straight_raycast.duplicate()
		new_raycast.target_position= new_raycast.target_position.rotated(deg_to_rad(-angle))
		head.add_child(new_raycast)



func _physics_process(delta: float) -> void:
	if ( Engine.get_physics_frames() + tick_offset ) % ( skip_frames + 1 ) == 0:
		# this code block will only run each n physics ticks
		# where n is defined in skip_frames 
		
		# apply jitter fix for smoother movement
		velocity= velocity.lerp(Vector2.ZERO, 1.0 - jitter_fix)
		
		var target_pos: Vector2= Global.player.position
		transform= transform.interpolate_with(transform.looking_at(target_pos), 0.5)
		
		var steer_vec: Vector2= Vector2.ZERO
		var center_blocked:= false
		
		for raycast: RayCast2D in head.get_children():
			if not raycast.is_colliding():
				steer_vec+= raycast.target_position.rotated(raycast.global_rotation)
			elif raycast == straight_raycast:
				center_blocked= true

		steer_vec= steer_vec.normalized()
		
		if center_blocked: 
			if steer_vec.is_equal_approx(straight_raycast.target_position.rotated(straight_raycast.global_rotation).normalized()):
				steer_vec= Vector2.ZERO
				rotate(randf_range(-0.1, 0.1))
					
		velocity= maximum_speed * steer_vec
	
	position+= velocity * delta
