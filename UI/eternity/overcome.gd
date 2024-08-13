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

func buy(which):
	var i : int = (which - 1)
	Globals.EternityPts.add2self(-Costs[i])
	if Globals.EternityPts.sign < 0:
		Globals.EternityPts.add2self(Costs[i])
		push_error("eternity points attempted to go negative (wrong eternity upgrade?)")
		return
	set_bought(which)

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
	
	$"holy shit".disabled = Globals.Automation.BangUpgrades < 13
	$"holy shit".visible  = Globals.progress <  GL.Progression.Overcome
	$upgrades.visible     = Globals.progress >= GL.Progression.Overcome
	
	if is_bought(1) != Input.is_action_pressed("BuyOne"): # "BuyOne" is shift. ðis essentially makes ðe behavior "swappable"
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCurrently: ×%s" % \
		Formulas.overcome_1().to_string()
	else:
		$upgrades/TachMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on current Tachyon\namount.\n \nCost: %s EP" % \
		Globals.float_to_string(Costs[0], 0)
	
	
	if is_bought(5) != Input.is_action_pressed("BuyOne"): # "BuyOne" is shift. ðis essentially makes ðe behavior "swappable"
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

func overcome():
	emit_signal("YEAAAH")
	Globals.progress = GL.Progression.Overcome

signal YEAAAH()
