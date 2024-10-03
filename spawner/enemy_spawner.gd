extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float= 0.1

@onready var timer: Timer = $Timer

var paused:= false



func _ready() -> void:
	timer.wait_time= spawn_interval
	timer.start()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_spawner"):
		paused= not paused


func spawn_enemy():
	if paused: return
	var obj: BaseEnemy= enemy_scene.instantiate()
	obj.position= position
	Global.enemies.add_child(obj)


func _on_timer_timeout() -> void:
	spawn_enemy()
	
