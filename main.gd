extends Node2D

@onready var enemies: Node2D = $Enemies



func _ready() -> void:
	Global.enemies= enemies
