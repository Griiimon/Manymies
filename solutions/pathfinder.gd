class_name Pathfinder
extends Node2D

@export var enabled: bool= true
@export var debug: bool= false

var busy: bool= false



func _ready() -> void:
	if enabled:
		Global.pathfinder= self


func get_grid_coords(pos: Vector2)-> Vector2i:
	return pos / Global.TILE_SIZE


func get_direction(from: Vector2)-> Vector2:
	return Vector2.ZERO 


func update(player_pos: Vector2, non_blocking: bool= true):
	pass
