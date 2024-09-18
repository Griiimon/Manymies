extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float= 0.1

@onready var timer: Timer = $Timer



func _ready() -> void:
	timer.wait_time= spawn_interval
	timer.start()


func spawn_enemy():
	var obj: BaseEnemy= enemy_scene.instantiate()
	obj.position= position
	Global.enemies.add_child(obj)


func _on_timer_timeout() -> void:
	spawn_enemy()
	
