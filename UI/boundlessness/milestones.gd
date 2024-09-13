extends MarginContainer

func _process(_delta):
	$Mile/M1.text = "Unlock the ×%s EP\nmultiplier autobuyer" % \
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
