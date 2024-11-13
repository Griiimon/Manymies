extends BaseEnemy


@export var maximum_speed: float= 25.0
@export var radius: float= 10.0

# with no randomization the enemies will move in lines
@export_range(0.0, 1.0) var randomize_direction: float= 0.1


# skip n calculation frames
@export var skip_frames: int= 20

@onready var collision_shape = $CollisionShape2D

# since the BaseEnemy class is supposed to work with any Node2D
# i need to get a little creative to cast this node into a Rigidbody2D
# in order to get autocompletion etc
@onready var rb: RigidBody2D= get_node(".")

# offset the tick used for skip_frames by a random number so
# it's more evenly spread out 
var tick_offset: int



func _ready():
	# Rigidbody settings changed in the editor/inspector:

		# - rb.gravity_scale= 0
		# - rb.lock_rotation= true
		# - rb.physics_material_override.friction= 0
		
		# ( rb.physics_material_override.bounce might be interesting to tweak )
		
		# to ensure there's no damping:
		# - rb.linear_damp_mode= RigidBody2D.DAMP_MODE_REPLACE
		# - rb.angular_damp_mode= RigidBody2D.DAMP_MODE_REPLACE
	
	(collision_shape.shape as CircleShape2D).radius= radius

	tick_offset= randi() % 60


func _physics_process(delta):
	if ( Engine.get_physics_frames() + tick_offset ) % ( skip_frames + 1 ) == 0:
		var pathfinder_dir: Vector2= Global.pathfinder.get_direction(position)

		var random_dir= Vector2(randf_range(-1, 1), randf_range(-1, 1))
		rb.linear_velocity= lerp(pathfinder_dir, random_dir, randomize_direction).normalized()  * maximum_speed
