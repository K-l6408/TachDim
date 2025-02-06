@tool
extends ColorRect

@export var fisheye := 0.0

func _process(delta):
	material.set_shader_parameter("fisheye", fisheye)
