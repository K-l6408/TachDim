extends Sprite2D

func screenshot():
	var image = get_viewport().get_texture().get_image()
	texture = ImageTexture.create_from_image(image)
	show()
