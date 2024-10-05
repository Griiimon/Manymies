extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float= 0.1
@export var wait_for_empty_space: bool= false
@export var empty_radius: float= 20.0

@onready var timer: Timer = $Timer

var paused:= false
var busy:= false
var empty_space_query: PhysicsShapeQueryParameters2D


func _ready() -> void:
	if wait_for_empty_space:
		var query:= PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas= true
		query.collide_with_bodies= true
		query.collision_mask= Global.ENEMY_COLLISION_LAYER + Global.RAYCAST_ENEMY_COLLISION_LAYER
		query.transform= transform
		var shape:= CircleShape2D.new()
		shape.radius= empty_radius
		query.shape= shape
		empty_space_query= query

	timer.wait_time= spawn_interval
	timer.start()




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_spawner"):
		paused= not paused


func spawn_enemy():
	if busy: return
	if paused: return
	if wait_for_empty_space:
		busy= true
		await get_tree().physics_frame
		busy= false
		var space_state: PhysicsDirectSpaceState2D= get_world_2d().direct_space_state
		if not space_state: return
		var result= space_state.intersect_shape(empty_space_query)
		if result: return
		
	var obj: BaseEnemy= enemy_scene.instantiate()
	obj.position= position
	Global.enemies.add_child(obj)


func _on_timer_timeout() -> void:
	spawn_enemy()
	
