class_name Player
extends CharacterBody2D

@export var player_speed: float= 50.0



func _init() -> void:
	Global.player= self


func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position= position.lerp(get_global_mouse_position(), player_speed * delta)
