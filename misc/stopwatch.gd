class_name Stopwatch

var time: float
var pause: bool:
	set(b):
		pause= b
		if pause:
			pause_time= Time.get_ticks_msec()
		else:
			exclude_time+= Time.get_ticks_msec() - pause_time

var pause_time: float
var exclude_time: float

func _init():
	time= Time.get_ticks_msec()
	
func stop(prefix: String= ""):
	var delta= Time.get_ticks_msec() - time - exclude_time
	print(prefix.rstrip(" ") + " ", delta, "ms")

func get_elapsed_secs()-> int:
	return int((Time.get_ticks_msec() - time) / 1000)
