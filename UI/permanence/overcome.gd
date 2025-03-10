extends Control

func _ready() -> void:
	for i in 9:
		$upgrades.get_child(i).connect("pressed", Permanence.buy_over.bind(i+1))
	for i in 3:
		$upgrades.get_child(i+9).connect("pressed", Permanence.buy_rebuyable.bind(i+1))
	$"holy shit".connect("pressed", overcome)

func _process(delta):
	for j in 9:
		if not $upgrades.get_child(j) is Button:
			continue
		
		if Permanence.overcome_upgrade_bought(j+1):
			$upgrades.get_child(j).disabled = true
			$upgrades.get_child(j).add_theme_stylebox_override("disabled", \
			get_theme_stylebox("enabled", "ButtonEtern"))
			continue
		else:
			$upgrades.get_child(j).remove_theme_stylebox_override("disabled")
			$upgrades.get_child(j).disabled = Currencies.PermanencePts.AMOUNT.less(
				Permanence.OvercomeCosts[j]
			)
	
	if Permanence.TSpScBought >= 8:
		Permanence.TSpScBought = 8
		$upgrades/TSpSc.disabled = true
		$upgrades/TSpSc.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/TSpSc.text = "%s\n%s %s.\n\n%s ×%s" % [
			"Reduce Timespeed Upgrade",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - Permanence.TSpScBought),
		]
	else:
		$upgrades/TSpSc.remove_theme_stylebox_override("disabled")
		$upgrades/TSpSc.disabled = Currencies.PermanencePts.AMOUNT.less(Permanence.tspsc_cost())
		$upgrades/TSpSc.text = "%s\n%s %s.\n\n%s ×%s\n%s ×%s\n%s %s %s" % [
			"Reduce Timespeed Upgrade",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - Permanence.TSpScBought),
			"Next:"     , Globals.int_to_string( 9 - Permanence.TSpScBought),
			"Cost:", Permanence.tspsc_cost(), "PP"
		]
	
	if Permanence.TDmScBought >= 7:
		Permanence.TDmScBought = 7
		$upgrades/TDmSc.disabled = true
		$upgrades/TDmSc.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/TDmSc.text = "%s\n%s %s.\n\n%s ×%s" % [
			"Reduce Tachyon Dimensions",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - Permanence.TDmScBought),
		]
	else:
		$upgrades/TDmSc.remove_theme_stylebox_override("disabled")
		$upgrades/TDmSc.disabled = Currencies.PermanencePts.AMOUNT.less(Permanence.tdmsc_cost())
		$upgrades/TDmSc.text = "%s\n%s %s.\n\n%s ×%s\n%s ×%s\n%s %s %s" % [
			"Reduce Tachyon Dimensions",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - Permanence.TDmScBought),
			"Next:"     , Globals.int_to_string( 9 - Permanence.TDmScBought),
			"Cost:", Permanence.tdmsc_cost(), "PP"
		]
	
	if Permanence.PasPPBought >= 10:
		Permanence.PasPPBought = 10
		$upgrades/PasPP.disabled = true
		$upgrades/PasPP.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/PasPP.text = "%s %s %s\n%s\n%s %s %s" % [
			"Passively generate", Globals.percent_to_string(Permanence.PasPPBought / 20., 0), "of",
			"your average PP gain", "over the last", Globals.int_to_string(10),
			"Permanences."
		]
	else:
		$upgrades/PasPP.remove_theme_stylebox_override("disabled")
		$upgrades/PasPP.disabled = Currencies.PermanencePts.AMOUNT.less(Permanence.paspp_cost())
		$upgrades/PasPP.text = "%s %s %s\n%s\n%s %s %s\n\n%s %s\n%s %s %s" % [
			"Passively generate", Globals.percent_to_string(Permanence.PasPPBought / 20., 0), "of",
			"your average PP gain", "over the last", Globals.int_to_string(10),
			"Permanences.", "Next:", Globals.percent_to_string((Permanence.PasPPBought + 1) / 20., 0),
			"Cost:", Permanence.paspp_cost(), "PP"
		]
	
	$"holy shit".disabled = Autobuyers.BangUpgrades < 13
	$"holy shit/Label".text = "Max out the Big Bang Autobuyer Interval\n" + \
	"to %s to Overcome Time." % Globals.format_time(0.1)
	$"holy shit".visible  = Globals.progressBL <  GL.Progression.Overcome
	$upgrades.visible     = Globals.progressBL >= GL.Progression.Overcome
	
	# "BuyOne" is shift. ðis essentially makes ðe behavior "swappable"
	if Permanence.overcome_upgrade_bought(1) != Input.is_action_pressed("BuyOne"):
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCurrently: ×%s" % \
		Formulas.overcome_1().to_string()
	else:
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCost: %s PP" % \
		Globals.float_to_string(Permanence.OvercomeCosts[0], 0)
	
	if Permanence.overcome_upgrade_bought(2) != Input.is_action_pressed("BuyOne"):
		$upgrades/MaxDila.text = \
		"Unlock the Buy Max Dilation\nAutobuyer mode."
	else:
		$upgrades/MaxDila.text = \
		"\nUnlock the Buy Max Dilation\nAutobuyer mode.\n\n\nCost: %s PP" % \
		Globals.float_to_string(Permanence.OvercomeCosts[1], 0)
	
	if Permanence.overcome_upgrade_bought(3) != Input.is_action_pressed("BuyOne"):
		$upgrades/GalStr.text = \
		"All Galaxies are\n%s stronger." % Globals.percent_to_string(.4, 0)
	else:
		$upgrades/GalStr.text = \
		"\nAll Galaxies are\n%s stronger.\n\n\nCost: %s PP" % \
		[Globals.percent_to_string(.4, 0), Globals.float_to_string(Permanence.OvercomeCosts[2], 0)]
	
	if Permanence.overcome_upgrade_bought(4) != Input.is_action_pressed("BuyOne"):
		$upgrades/EPForm.text = "Improve the PP gain formula\n" + \
		"(log₂(x)/%s → log₂(x)/%s)" % [
			Globals.int_to_string(1024), Globals.int_to_string(900)
		]
	else:
		$upgrades/EPForm.text = "\nImprove the PP gain formula\n" + \
		"(log₂(x)/%s → log₂(x)/%s)" % [
			Globals.int_to_string(1024), Globals.int_to_string(900)
		] + "\n\n\nCost: %s PP" % Globals.float_to_string(Permanence.OvercomeCosts[3], 0)
	
	if Permanence.overcome_upgrade_bought(5) != Input.is_action_pressed("BuyOne"):
		$upgrades/DilaBoost.text = \
		"Improve the Dilation\nmultiplier further.\n\n(×%s → ×%s)" % [
			Globals.float_to_string(2.5, 1), Globals.float_to_string(3, 1)
		]
	else:
		$upgrades/DilaBoost.text = \
		"Improve the Dilation\nmultiplier further.\n\n(×%s → ×%s)\n\nCost: %s PP" % [
			Globals.float_to_string(2.5, 1), Globals.float_to_string(3, 1),
			Globals.float_to_string(Permanence.OvercomeCosts[4], 0)
		]
	
	if Permanence.overcome_upgrade_bought(6) != Input.is_action_pressed("BuyOne"):
		$upgrades/RewdFormula.text = \
		"Improve the Rewind formula\nfrom being based on\nthe %s TD's logarithm" % \
		Globals.ordinal(1) + "\nto using a very low exponent."
	else:
		$upgrades/RewdFormula.text = \
		"Improve the Rewind formula\nfrom being based on\nthe %s TD's logarithm" % \
		Globals.ordinal(1) + "\nto using a very low exponent.\n\nCost: %s PP" % \
		Globals.float_to_string(Permanence.OvercomeCosts[5], 0)
	
	if Permanence.overcome_upgrade_bought(7) != Input.is_action_pressed("BuyOne"):
		var worst = 0
		var worsttime = -1
		for ch in 15:
			if Globals.challengeTimes[ch] > worsttime:
				worsttime = Globals.challengeTimes[ch]
				worst     =                    1 + ch
		$upgrades/ChallengeMult.text = \
		"Tachyon Dimensions get a\nmultiplier based on your\nslowest Challenge." + \
		"\n\nCurrently: ×%s\n(%s)" % [
			Globals.float_to_string(Formulas.overcome_7()),
			"Not all Challenges completed" if (worsttime < 0 or worst == 0) else \
			"Challenge %s: %s" % [
				Globals.int_to_string(worst), Globals.format_time(worsttime)
			]
		]
	else:
		$upgrades/ChallengeMult.text = \
		"Tachyon Dimensions get a\nmultiplier based on your\nslowest Challenge." + \
		"\n\n\nCost: %s PP" % Globals.float_to_string(Permanence.OvercomeCosts[6], 0)
	
	if Permanence.overcome_upgrade_bought(8) != Input.is_action_pressed("BuyOne"):
		$upgrades/PasEter.text = \
		"\nGain Eternities passively\nbased on your fastest\nEternity." + \
		"\n\nCurrently: %s/sec" % \
		Globals.fastestEtern.amount.divide(Globals.fastestEtern.time / 10)
	else:
		$upgrades/PasEter.text = \
		"\nGain Eternities passively\nbased on your fastest\nEternity." + \
		"\n\nCost: %s PP" % Globals.float_to_string(Permanence.OvercomeCosts[7], 0)
	
	if Permanence.overcome_upgrade_bought(9) != Input.is_action_pressed("BuyOne"):
		$upgrades/EterMult.text = \
		"\nTachyon Dimensions get a\nmultiplier based on\nEternities." + \
		"\n\nCurrently: ×%s" % Formulas.overcome_9().to_string()
	else:
		$upgrades/EterMult.text = \
		"\nTachyon Dimensions get a\nmultiplier based on\nEternities." + \
		"\n\nCost: %s PP" % Globals.float_to_string(Permanence.OvercomeCosts[8], 0)
	
	if Permanence.overcome_upgrade_bought(8):
		Currencies.PermanencePts.spend(
			Globals.fastestEtern.amount.divide(
				Globals.fastestEtern.time / delta / 10
			)
		)
	#if Globals.Eternities.sign < 0:
		#Globals.Eternities = largenum.new(0)

func overcome():
	Globals.animation(GL.Animations.Overcome)
	if Globals.progress < GL.Progression.Overcome:
		Globals.progress = GL.Progression.Overcome
	Globals.progressBL = GL.Progression.Overcome
	if not Globals.Achievemer.is_unlocked(5, 1):
		Globals.Achievemer.set_unlocked(5, 1)
