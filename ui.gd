extends CanvasLayer

@onready var label_fps: Label = %"Label FPS"
@onready var label_enemies: Label = %"Label Enemies"



func _physics_process(_delta: float) -> void:
	label_fps.text= str("FPS: ", Engine.get_frames_per_second())
	label_enemies.text= str("Enemies: ", Global.enemies.get_child_count())
