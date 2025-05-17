extends Control

var index: int = 0
var amplitude := 5.0
var speed := 2.0
var original_position := Vector2.ZERO
var time_offset := 0.0



func _process(_delta):
	var wave_offset = sin(Time.get_ticks_msec() / 1000.0 * speed + index) * amplitude
	
	var forward = Vector2.UP.rotated(rotation)
	global_position = original_position + forward * wave_offset
