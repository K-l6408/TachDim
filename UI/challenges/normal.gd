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
				get_theme_stylebox("pressed", "Button")
			)
		else:
			if Globals.Challenge == i:
				$Chal/lenges.get_child(i).get_node("Start").text = "Restart"
			else:
				$Chal/lenges.get_child(i).get_node("Start").text = "Start challenge"
			$Chal/lenges.get_child(i).get_node("Start").remove_theme_stylebox_override("normal")
		if i <= 8:
			$Chal/lenges.get_child(i).get_node("Reward").text = "Reward: Upgradeable %s TD autobuyer" % Globals.ordinal(i)
	
	$Chal/lenges/C2/Condition.text = "Buying Tachyon Dimensions temporairly stops production. " +\
	"After that, it will increase linearly and arrive at %s in %s minute." % \
	[Globals.percent_to_string(1,0), Globals.int_to_string(1)]
	
	$Chal/lenges/C3/Condition.text = "The %s Tachyon Dimension is stronger, " % Globals.ordinal(3) \
	+ "but the %s and %s are weaker." % [Globals.ordinal(1), Globals.ordinal(2)]
	
	$Chal/lenges/C4/Condition.text = "The multiplier for buying %s dimensions is" % \
	Globals.int_to_string(10) + " reduced to ×%s, and increases by %s for each Time Dilation." % \
	[Globals.float_to_string(1), Globals.float_to_string(.2)]
	
	$Chal/lenges/C5/Condition.text = "Tachyon Dimensions take " + \
	"%s purchases instead of %s to increase their multiplier." % \
	[Globals.int_to_string(15), Globals.int_to_string(10)] + \
	" Dilation, Galaxies and Timespeed upgrades are more expensive."
	
	$Chal/lenges/C6/Condition.text = "The %s and %s Dimensions are " % \
	[Globals.ordinal(7), Globals.ordinal(8)] + \
	"disabled, but Dilation and Galaxies are cheaper."
	
	$Chal/lenges/C11/Condition.text = "You start with -%s Dilation, locking all " % Globals.int_to_string(3) + \
	"Tachyon Dimensions except the %s." % Globals.ordinal(1)
	
	$Chal/lenges/C12/Condition.text = "Timespeed strength starts at %s instead of %s." % \
	[Globals.float_to_string(1.1), Globals.float_to_string(1.13)]
	
	$Chal/lenges/C13/Condition.text = "%s %s %s" % [
		"All TD multipliers are disabled except for the one from Dilation and the Buy",
		Globals.int_to_string(10),
		"multiplier. However, Rewind affects all Dimensions."
	]
	
	if Globals.Challenge == 0:
		$CurrentChallenge/Label.text = "You aren't in any challenge."
		$CurrentChallenge/Exit.visible = false
	else:
		$CurrentChallenge/Label.text = "You are currently in %schallenge %s." % [
			"" if Globals.Challenge <= 15 else "eternity ",
			Globals.int_to_string((Globals.Challenge - 1) % 15 + 1)
		]
		$CurrentChallenge/Exit.visible = true
