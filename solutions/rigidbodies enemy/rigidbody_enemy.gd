extends BaseEnemy


@export var maximum_speed: float= 25.0
@export var radius: float= 10.0
@export var randomize_direction: float= 0.1
@export var skip_frames: int= 20

@onready var collision_shape = $CollisionShape2D
@onready var rb: RigidBody2D= get_node(".")

var tick_offset: int



func _ready():
	(collision_shape.shape as CircleShape2D).radius= radius

	tick_offset= randi() % 60


func _physics_process(delta):
	if ( Engine.get_physics_frames() + tick_offset ) % ( skip_frames + 1 ) == 0:
		var pathfinder_dir: Vector2= Global.pathfinder.get_direction(position)
		var random_dir= Vector2(randf_range(-1, 1), randf_range(-1, 1))
		rb.linear_velocity= lerp(pathfinder_dir, random_dir, randomize_direction).normalized()  * maximum_speed
