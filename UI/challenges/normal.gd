extends Control

func challenge_start(which):
	Globals.Challenge = which
	Globals.TDHandler.reset(2, false)

func _process(_delta):
	$Chal/lenges/Separator.custom_minimum_size = Vector2.ZERO
	$Chal/lenges.size = Vector2.ZERO
	$Chal/lenges/Separator.custom_minimum_size = Vector2(size.x, 10)
	for i in $Chal/lenges.get_child_count():
		if i == 0: continue
		$Chal/lenges.get_child(i).get_node("Name").text = "C%s" % Globals.int_to_string(i)
		if Globals.challengeCompleted(i):
			$Chal/lenges.get_child(i).get_node("Start").text = "Completed"
			$Chal/lenges.get_child(i).get_node("Start").add_theme_stylebox_override(
				"normal",
				load(ProjectSettings.get("gui/theme/custom")).get_stylebox("pressed", "Button")
			)
		else:
			if Globals.Challenge == i:
				$Chal/lenges.get_child(i).get_node("Start").text = "Restart"
			else:
				$Chal/lenges.get_child(i).get_node("Start").text = "Start challenge"
			$Chal/lenges.get_child(i).get_node("Start").remove_theme_stylebox_override("normal")
		if i <= 8:
			$Chal/lenges.get_child(i).get_node("Reward").text = "Reward: Upgradeable %s TD autobuyer" % Globals.ordinal(i)
	
	$Chal/lenges/C2/Condition.text = "Buying Tachyon\nDimensions temporairly\nstops production." +\
	"\nAfter that, it will\nincrease linearly\nand arrive at %s in\n%s minute." % \
	[Globals.percent_to_string(1,0), Globals.int_to_string(1)]
	
	$Chal/lenges/C3/Condition.text = "The %s Tachyon\nDimension is stronger,\n" % Globals.ordinal(3) \
	+ "but the %s and %s\nare weaker." % [Globals.ordinal(1), Globals.ordinal(2)]
	
	$Chal/lenges/C4/Condition.text = "The multiplier for\nbuying %s dimensions is" % \
	Globals.int_to_string(10) + "\nreduced to ×%s, and\nincreases by %s for\neach Time Dilation." % \
	[Globals.float_to_string(1), Globals.float_to_string(.2)]
	
	$Chal/lenges/C5/Condition.text = "Tachyon Dimensions take\n" + \
	"%s purchases instead of\n%s to increase their\nmultiplier." % \
	[Globals.int_to_string(15), Globals.int_to_string(10)] + \
	"\nDilation and Galaxies\nare more expensive."
	
	$Chal/lenges/C6/Condition.text = "The %s and %s\nDimensions are\n" % \
	[Globals.ordinal(7), Globals.ordinal(8)] + \
	"disabled, but\nDilation and Galaxies\nare cheaper."
	
	$Chal/lenges/C11/Condition.text = "You start with %s\nDilation, locking all" % Globals.int_to_string(-3) + \
	"\nTachyon Dimensions\nexcept the %s." % Globals.ordinal(1)
	
	$Chal/lenges/C12/Condition.text = "Timespeed strength\nstarts at %s instead\nof %s." % \
	[Globals.float_to_string(1.1), Globals.float_to_string(1.13)]
	
	if Globals.Challenge == 0:
		$CurrentChallenge/Label.text = "You aren't in any challenge."
		$CurrentChallenge/Exit.visible = false
	else:
		$CurrentChallenge/Label.text = "You are currently in challenge %s." % \
		Globals.int_to_string(Globals.Challenge)
		$CurrentChallenge/Exit.visible = true
