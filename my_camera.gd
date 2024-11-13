extends Camera2D


@export var pan_speed: float= 100.0



func _process(delta: float):
	position+= Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * pan_speed * delta / zoom.x
	
	zoom*= (1 + Input.get_axis("ui_page_up", "ui_page_down") * delta)
