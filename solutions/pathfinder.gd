class_name Pathfinder
extends Node

@export var enabled: bool= true

var busy: bool= false



func _ready() -> void:
	if enabled:
		Global.pathfinder= self


func get_direction(from: Vector2)-> Vector2:
	return Vector2.ZERO 


func update(player_pos: Vector2, non_blocking: bool= true):
	pass
