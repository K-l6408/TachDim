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
		$Chal/lenges.get_child(i).get_node("Name").text = "EC%s" % Globals.int_to_string(i)
		if Globals.ECCompleted(i):
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
	
	$Chal/lenges/EC1/Condition.text = \
	"Challenges %s, %s, %s, %s, %s and %s's restrictions all apply at once." % [
		Globals.int_to_string(1), Globals.int_to_string( 2), Globals.int_to_string( 5),
		Globals.int_to_string(6), Globals.int_to_string(11), Globals.int_to_string(14)
	]
	$Chal/lenges/EC1/ReqRew.text = \
	"[center]Requirement: %s TC\n\nReward: ×%s on all TDs for each EC completion." % [
		Globals.ECTargets[0].to_string(), Globals.int_to_string(3)
	] + "\n(Currently: ×%s)" % Globals.int_to_string(Formulas.ec1_reward())
	$Chal/lenges/EC1.visible = Globals.TachTotal.log10() >= Globals.ECUnlocks[0]
	
	if Globals.Challenge == 0:
		$CurrentChallenge/Label.text = "You aren't in any challenge."
		$CurrentChallenge/Exit.visible = false
	else:
		$CurrentChallenge/Label.text = "You are currently in %schallenge %s." % [
			"" if Globals.Challenge <= 15 else "eternity",
			Globals.int_to_string((Globals.Challenge - 1) % 15 + 1)
		]
		$CurrentChallenge/Exit.visible = true
