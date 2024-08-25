extends Control

func challenge_start(which):
	Globals.Challenge = which
	Globals.TDHandler.reset(2, false)

func _process(_delta):
	$Chal/lenges/Separator.custom_minimum_size = Vector2.ZERO
	$Chal/lenges.size = Vector2.ZERO
	$Chal/lenges/Separator.custom_minimum_size = Vector2(size.x, 10)
	var seen = 0
	for i in $Chal/lenges.get_child_count():
		if i == 0: continue
		$Chal/lenges.get_child(i).get_node("Name").text = "EC%s" % Globals.int_to_string(i)
		$Chal/lenges.get_child(i).visible = Globals.TachTotal.log10() >= Globals.ECUnlocks[i-1]
		if $Chal/lenges.get_child(i).visible: seen += 1
		if Globals.ECCompleted(i):
			$Chal/lenges.get_child(i).get_node("Start").text = "Completed"
			$Chal/lenges.get_child(i).get_node("Start").add_theme_stylebox_override(
				"normal",
				get_theme_stylebox("pressed", "Button")
			)
		else:
			if Globals.Challenge == i + 15:
				$Chal/lenges.get_child(i).get_node("Start").text = "Restart"
			else:
				$Chal/lenges.get_child(i).get_node("Start").text = "Start challenge"
			$Chal/lenges.get_child(i).get_node("Start").remove_theme_stylebox_override("normal")
	
	if seen < $Chal/lenges.get_child_count() - 1:
		$Meow.text = "You have seen %s out of %s Eternity Challenges." % \
		[Globals.int_to_string(seen), Globals.int_to_string($Chal/lenges.get_child_count() - 1)] + \
		"\nThe next EC is unlocked at %s total Tachyons." % \
		largenum.ten_to_the(Globals.ECUnlocks[seen])
	else:
		$Meow.text = "You have seen all %s Eternity Challenges." % Globals.int_to_string(seen)
	
	$Chal/lenges/EC1/Condition.text = \
	"Challenges %s, %s, %s, %s, %s and %s's restrictions all apply at once." % [
		Globals.int_to_string(1), Globals.int_to_string( 2), Globals.int_to_string( 5),
		Globals.int_to_string(6), Globals.int_to_string(11), Globals.int_to_string(14)
	]
	$Chal/lenges/EC1/ReqRew.text = \
	"[center]Requirement: %s TC\n\nReward: ×%s on all TDs for each EC completion." % [
		Globals.ECTargets[0].to_string(), Globals.int_to_string(3)
	] + "\n(Currently: ×%s)" % Globals.int_to_string(Formulas.ec1_reward())
	
	$Chal/lenges/EC2/Condition.text = \
	"Eternity Dimensions' multipliers are raised ^%s." % Globals.float_to_string(0.2)
	$Chal/lenges/EC2/ReqRew.text = \
	"[center]Requirement: %s TC\n" % \
	Globals.ECTargets[1].to_string() + \
	"\nReward: Timespeed affects Eternity Dimensions with greatly reduced effeect."
	
	$Chal/lenges/EC3/Condition.text = \
	"All Tachyon Dimensions except the latest purchased are raised ^%s." % \
	Globals.float_to_string(0.2, 1)
	$Chal/lenges/EC3/ReqRew.text = \
	"[center]Requirement: %s TC\n" % \
	Globals.ECTargets[2].to_string() + \
	"\nReward: Unlock Duplicantes."
	
	if Globals.Challenge == 0:
		$CurrentChallenge/Label.text = "You aren't in any challenge."
		$CurrentChallenge/Exit.visible = false
	else:
		$CurrentChallenge/Label.text = "You are currently in %schallenge %s." % [
			"" if Globals.Challenge <= 15 else "eternity ",
			Globals.int_to_string((Globals.Challenge - 1) % 15 + 1)
		]
		$CurrentChallenge/Exit.visible = true
