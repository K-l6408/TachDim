extends Node

func _process(delta: float) -> void:
	
	
	if Input.is_key_label_pressed(KEY_ALT):
		pass
	else:
		for k in 8:
			if Input.is_key_label_pressed(KEY_1 + k) or \
			Input.is_key_label_pressed(KEY_KP_1 + k):
				if Input.is_key_label_pressed(KEY_SHIFT):
					TachyonDims.buy_one(k+1)
				else:
					TachyonDims.buy_until_mult(k+1, true)
		
		if Input.is_key_label_pressed(KEY_L) and\
		TachyonDims.canDilate:
			TachyonDims.dilate()
		if Input.is_key_label_pressed(KEY_R) and\
		TachyonDims.canRewind:
			TachyonDims.rewind()
		if Input.is_key_label_pressed(KEY_G) and\
		TachyonDims.canGalaxy:
			TachyonDims.galaxy()
	
	if Input.is_key_label_pressed(KEY_M):
		for i in 8:
			TachyonDims.buy_max(i+1)
		TachyonDims.buy_max_tspeed()
	
