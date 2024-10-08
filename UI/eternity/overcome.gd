extends Control

var Bought := 0
var Costs := [
	1e3, 1e6, 1e9,
	3e6, 1e4, 4e4,
	1e5, 2e8, 1e7
]
var TSpScBought := 0
var TDmScBought := 0
var PasEPBought := 0

func is_bought(which):
	return ((Bought >> (which - 1)) & 1) == 1

func set_bought(which, what := true):
	if what:
		Bought |= \
		1 << (which - 1)
	else:
		Bought &= 1023 - \
		1 << (which - 1)

func tspsc_cost():
	return largenum.ten_to_the(4   + 1.5     * TSpScBought)
func tdmsc_cost():
	return largenum.ten_to_the(4.5 + 2.33333 * TDmScBought)
func pasep_cost():
	return largenum.ten_to_the(5   + 0.66666 * PasEPBought)

func buy(which):
	var i : int = (which - 1)
	Globals.EternityPts.add2self(-Costs[i])
	if Globals.EternityPts.sign < 0:
		Globals.EternityPts.add2self(Costs[i])
		push_error("eternity points attempted to go negative (wrong eternity upgrade?)")
		return
	set_bought(which)

func buy_rebuyable(which):
	match which:
		1:
			Globals.EternityPts.add2self(tspsc_cost().neg())
			if Globals.EternityPts.sign < 0:
				Globals.EternityPts.add2self(tspsc_cost())
				push_error("eternity points attempted to go negative (wrong eternity upgrade?)")
				return
			TSpScBought += 1
		2:
			Globals.EternityPts.add2self(tdmsc_cost().neg())
			if Globals.EternityPts.sign < 0:
				Globals.EternityPts.add2self(tdmsc_cost())
				push_error("eternity points attempted to go negative (wrong eternity upgrade?)")
				return
			TDmScBought += 1
		3:
			Globals.EternityPts.add2self(pasep_cost().neg())
			if Globals.EternityPts.sign < 0:
				Globals.EternityPts.add2self(pasep_cost())
				push_error("eternity points attempted to go negative (wrong eternity upgrade?)")
				return
			PasEPBought += 1

func _process(delta):
	for j in 9:
		if not $upgrades.get_child(j) is Button:
			continue
		
		if is_bought(j+1):
			$upgrades.get_child(j).disabled = true
			$upgrades.get_child(j).add_theme_stylebox_override("disabled", \
			get_theme_stylebox("enabled", "ButtonEtern"))
			continue
		else:
			$upgrades.get_child(j).remove_theme_stylebox_override("disabled")
			$upgrades.get_child(j).disabled = Globals.EternityPts.less(Costs[j])
	
	if TSpScBought >= 8:
		TSpScBought = 8
		$upgrades/TSpSc.disabled = true
		$upgrades/TSpSc.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/TSpSc.text = "%s\n%s %s.\n\n%s ×%s" % [
			"Reduce Timespeed Upgrade",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - TSpScBought),
		]
	else:
		$upgrades/TSpSc.remove_theme_stylebox_override("disabled")
		$upgrades/TSpSc.disabled = Globals.EternityPts.less(tspsc_cost())
		$upgrades/TSpSc.text = "%s\n%s %s.\n\n%s ×%s\n%s ×%s\n%s %s %s" % [
			"Reduce Timespeed Upgrade",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - TSpScBought),
			"Next:"     , Globals.int_to_string( 9 - TSpScBought),
			"Cost:", tspsc_cost(), "EP"
		]
	
	if TDmScBought >= 7:
		TDmScBought = 7
		$upgrades/TDmSc.disabled = true
		$upgrades/TDmSc.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/TDmSc.text = "%s\n%s %s.\n\n%s ×%s" % [
			"Reduce Tachyon Dimensions",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - TDmScBought),
		]
	else:
		$upgrades/TDmSc.remove_theme_stylebox_override("disabled")
		$upgrades/TDmSc.disabled = Globals.EternityPts.less(tdmsc_cost())
		$upgrades/TDmSc.text = "%s\n%s %s.\n\n%s ×%s\n%s ×%s\n%s %s %s" % [
			"Reduce Tachyon Dimensions",
			"cost scaling after", largenum.two_to_the(1024).to_string(),
			"Currently:", Globals.int_to_string(10 - TDmScBought),
			"Next:"     , Globals.int_to_string( 9 - TDmScBought),
			"Cost:", tdmsc_cost(), "EP"
		]
	
	if PasEPBought >= 10:
		PasEPBought = 10
		$upgrades/PasEP.disabled = true
		$upgrades/PasEP.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
		$upgrades/PasEP.text = "%s %s %s\n%s\n%s %s %s" % [
			"Passively generate", Globals.percent_to_string(PasEPBought / 20., 0), "of",
			"your average EP gain", "over the last", Globals.int_to_string(10),
			"Eternities."
		]
	else:
		$upgrades/PasEP.remove_theme_stylebox_override("disabled")
		$upgrades/PasEP.disabled = Globals.EternityPts.less(pasep_cost())
		$upgrades/PasEP.text = "%s %s %s\n%s\n%s %s %s\n\n%s %s\n%s %s %s" % [
			"Passively generate", Globals.percent_to_string(PasEPBought / 20., 0), "of",
			"your average EP gain", "over the last", Globals.int_to_string(10),
			"Eternities.", "Next:", Globals.percent_to_string((PasEPBought + 1) / 20., 0),
			"Cost:", pasep_cost(), "EP"
		]
	
	$"holy shit".disabled = Globals.Automation.BangUpgrades < 13
	$"holy shit/Label".text = "Max out the Big Bang Autobuyer Interval\n" + \
	"to %s to Overcome Eternity." % Globals.format_time(0.1)
	$"holy shit".visible  = Globals.progressBL <  GL.Progression.Overcome
	$upgrades.visible     = Globals.progressBL >= GL.Progression.Overcome
	
	# "BuyOne" is shift. ðis essentially makes ðe behavior "swappable"
	if is_bought(1) != Input.is_action_pressed("BuyOne"):
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCurrently: ×%s" % \
		Formulas.overcome_1().to_string()
	else:
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCost: %s EP" % \
		Globals.float_to_string(Costs[0], 0)
	
	if is_bought(2) != Input.is_action_pressed("BuyOne"):
		$upgrades/MaxDila.text = \
		"Unlock the Buy Max Dilation\nAutobuyer mode."
	else:
		$upgrades/MaxDila.text = \
		"\nUnlock the Buy Max Dilation\nAutobuyer mode.\n\n\nCost: %s EP" % \
		Globals.float_to_string(Costs[1], 0)
	
	if is_bought(3) != Input.is_action_pressed("BuyOne"):
		$upgrades/GalStr.text = \
		"All Galaxies are\n%s stronger." % Globals.percent_to_string(.4, 0)
	else:
		$upgrades/GalStr.text = \
		"\nAll Galaxies are\n%s stronger.\n\n\nCost: %s EP" % \
		[Globals.percent_to_string(.4, 0), Globals.float_to_string(Costs[2], 0)]
	
	if is_bought(4) != Input.is_action_pressed("BuyOne"):
		$upgrades/EPForm.text = "Improve the EP gain formula\n" + \
		"(log₂(x)/%s → log₂(x)/%s)" % [
			Globals.int_to_string(1024), Globals.int_to_string(900)
		]
	else:
		$upgrades/EPForm.text = "\nImprove the EP gain formula\n" + \
		"(log₂(x)/%s → log₂(x)/%s)" % [
			Globals.int_to_string(1024), Globals.int_to_string(900)
		] + "\n\n\nCost: %s EP" % Globals.float_to_string(Costs[3], 0)
	
	if is_bought(5) != Input.is_action_pressed("BuyOne"):
		$upgrades/DilaBoost.text = \
		"Improve the Dilation\nmultiplier further.\n\n(×%s → ×%s)" % [
			Globals.float_to_string(2.5, 1), Globals.float_to_string(3, 1)
		]
	else:
		$upgrades/DilaBoost.text = \
		"Improve the Dilation\nmultiplier further.\n\n(×%s → ×%s)\n\nCost: %s EP" % [
			Globals.float_to_string(2.5, 1), Globals.float_to_string(3, 1),
			Globals.float_to_string(Costs[4], 0)
		]
	
	if is_bought(6) != Input.is_action_pressed("BuyOne"):
		$upgrades/RewdFormula.text = \
		"Improve the Rewind formula\nfrom being based on\nthe %s TD's logarithm" % \
		Globals.ordinal(1) + "\nto using a very low exponent."
	else:
		$upgrades/RewdFormula.text = \
		"Improve the Rewind formula\nfrom being based on\nthe %s TD's logarithm" % \
		Globals.ordinal(1) + "\nto using a very low exponent.\n\nCost: %s EP" % \
		Globals.float_to_string(Costs[5], 0)
	
	if is_bought(7) != Input.is_action_pressed("BuyOne"):
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
		"\n\n\nCost: %s EP" % Globals.float_to_string(Costs[6], 0)
	
	if is_bought(8) != Input.is_action_pressed("BuyOne"):
		$upgrades/PasEter.text = \
		"\nGain Eternities passively\nbased on your fastest\nEternity." + \
		"\n\nCurrently: %s/sec" % \
		Globals.fastestEtern.amount.divide(Globals.fastestEtern.time / 10)
	else:
		$upgrades/PasEter.text = \
		"\nGain Eternities passively\nbased on your fastest\nEternity." + \
		"\n\nCost: %s EP" % Globals.float_to_string(Costs[7], 0)
	
	if is_bought(9) != Input.is_action_pressed("BuyOne"):
		$upgrades/EterMult.text = \
		"\nTachyon Dimensions get a\nmultiplier based on\nEternities." + \
		"\n\nCurrently: ×%s" % Formulas.overcome_9().to_string()
	else:
		$upgrades/EterMult.text = \
		"\nTachyon Dimensions get a\nmultiplier based on\nEternities." + \
		"\n\nCost: %s EP" % Globals.float_to_string(Costs[8], 0)
	
	if is_bought(8):
		Globals.Eternities.add2self(
			Globals.fastestEtern.amount.divide(
				Globals.fastestEtern.time / delta / 10
			)
		)
	if Globals.Eternities.sign < 0:
		Globals.Eternities = largenum.new(0)

func overcome():
	emit_signal("YEAAAH")
	if Globals.progress < GL.Progression.Overcome:
		Globals.progress = GL.Progression.Overcome
	Globals.progressBL = GL.Progression.Overcome
	if not Globals.Achievemer.is_unlocked(5, 1):
		Globals.Achievemer.set_unlocked(5, 1)

signal YEAAAH()
