extends MarginContainer

func _process(_delta):
	$Mile/M1.text = "Unlock the ×%s EP\nmultiplier autobuyer." % \
	Globals.int_to_string(2)
	$Mile/M1/Label.text = "At %s Boundlessness:" % Globals.int_to_string(1)
	$Mile/M1.button_pressed = Globals.Boundlessnesses.to_float() >= 1
	
	$Mile/M2/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(2)
	$Mile/M2.button_pressed = Globals.Boundlessnesses.to_float() >= 2
	
	$Mile/M3/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(3)
	$Mile/M3.button_pressed = Globals.Boundlessnesses.to_float() >= 3
	
	$Mile/M4/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(4)
	$Mile/M4.button_pressed = Globals.Boundlessnesses.to_float() >= 4
	
	$Mile/M5/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(5)
	$Mile/M5.button_pressed = Globals.Boundlessnesses.to_float() >= 5
	
	$Mile/M6/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(6)
	$Mile/M6.button_pressed = Globals.Boundlessnesses.to_float() >= 6
	
	$Mile/M7/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(7)
	$Mile/M7.button_pressed = Globals.Boundlessnesses.to_float() >= 7
	
	$Mile/M8/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(8)
	$Mile/M8.button_pressed = Globals.Boundlessnesses.to_float() >= 8
	
	$Mile/M9/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(9)
	$Mile/M9.button_pressed = Globals.Boundlessnesses.to_float() >= 9
	
	$Mile/M10/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(10)
	$Mile/M10.button_pressed = Globals.Boundlessnesses.to_float() >= 10
	
	for i in 8:
		get_node("Mile/M1%d/Label" % (i+1)).text = \
		"At %s Boundlessnesses:" % Globals.int_to_string(11+i)
		get_node("Mile/M1%d" % (i+1)).text = \
		"Unlock an autobuyer\nfor the %s\nEternity Dimension." % \
		Globals.ordinal(i+1)
		get_node("Mile/M1%d" % (i+1)).button_pressed = \
		Globals.Boundlessnesses.to_float() >= 11+i
	
	$Mile/M25/Label.text = "At %s Boundlessnesses:" % Globals.int_to_string(25)
	$Mile/M25.button_pressed = Globals.Boundlessnesses.to_float() >= 25
	
