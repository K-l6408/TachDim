@tool
extends Sprite2D

@export var fisheye := 0.0

func _process(delta):
	material.set_shader_parameter("fisheye", fisheye)
	#if not visible:
		#texture = null

func screenshot() -> void:
	var image = get_viewport().get_texture().get_image()
	texture = ImageTexture.create_from_image(image)
