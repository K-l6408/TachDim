extends Control

var Bought := 0
var Costs := [
	[1, 1, 1, 2], [1, 1, 1, 2], [3, 5, 7, 10], [20, 30, 40, 75]
]

func is_bought(which):
	return ((Bought >> (which - 1)) & 1) == 1

func set_bought(which, what := true):
	if what:
		Bought |= \
		1 << (which - 1)
	else:
		Bought &= 65535 - \
		1 << (which - 1)

func buy(which):
	var i : int = (which - 1) / 4
	var j : int = (which - 1) % 4
	Globals.EternityPts.add2self(-Costs[i][j])
	set_bought(which)

func _process(delta):
	for i in $Columns.get_child_count():
		var k = $Columns.get_child(i)
		for j in k.get_child_count():
			if not k.get_child(j) is Button: break
			
			if is_bought(i*4+j+1):
				k.get_child(j).disabled = true
				k.get_child(j).add_theme_stylebox_override("disabled", \
				load(ProjectSettings.get("gui/theme/custom")).\
				get_stylebox("enabled", "ButtonEtern"))
				continue
			else:
				k.get_child(j).remove_theme_stylebox_override("disabled")
			
			k.get_child(j).disabled = \
			Globals.EternityPts.less(Costs[i][j])
			if j > 0 and not is_bought(i*4+j):
				k.get_child(j).disabled = true
	
	if is_bought(1):
		$Columns/Col1/TimePlayed.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on time played.\n \nCurrently: ×%s" % \
		Globals.float_to_string(Formulas.eternity_11())
	else:
		$Columns/Col1/TimePlayed.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on time played.\n \nCost: %s EP" % \
		Globals.int_to_string(Costs[0][0])
	
	if is_bought(2):
		$Columns/Col1/Dim18mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCurrently: ×%s" % \
		[Globals.ordinal(1), Globals.ordinal(8), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col1/Dim18mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCost: %s EP" % \
		[Globals.ordinal(1), Globals.ordinal(8), Globals.int_to_string(Costs[0][1])]
	
	if is_bought(3):
		$Columns/Col1/Dim27mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCurrently: ×%s" % \
		[Globals.ordinal(2), Globals.ordinal(7), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col1/Dim27mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCost: %s EP" % \
		[Globals.ordinal(2), Globals.ordinal(7), Globals.int_to_string(Costs[0][2])]
	
	if is_bought(4):
		$Columns/Col1/DGCheaper.text = \
		"Dilation and Galaxies\nare cheaper by\n%s and %s Dimensions,\nrespectively." % \
		[Globals.int_to_string(5), Globals.int_to_string(10)]
	else:
		$Columns/Col1/DGCheaper.text = \
		"Dilation and Galaxies\nare cheaper by\n%s and %s Dimensions,\nrespectively.\nCost: %s EP" % \
		[Globals.int_to_string(5), Globals.int_to_string(10), Globals.int_to_string(Costs[0][3])]
	
	if is_bought(5):
		$Columns/Col2/MultIncrease.text = \
		"Increase the multiplier\nfor buying %s\nTachyon Dimensions.\n \n(×%s → ×%s)" % \
		[Globals.int_to_string(10),
		Globals.float_to_string(2), Globals.float_to_string(2.22222)]
	else:
		$Columns/Col2/MultIncrease.text = \
		"Increase the multiplier\nfor buying %s\nTachyon Dimensions.\n(×%s → ×%s)\nCost: %s EP" % \
		[Globals.int_to_string(10),
		Globals.float_to_string(2), Globals.float_to_string(2.22222),
		Globals.int_to_string(Costs[1][0])]
	
	if is_bought(6):
		$Columns/Col2/Dim45mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCurrently: ×%s" % \
		[Globals.ordinal(4), Globals.ordinal(5), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col2/Dim45mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCost: %s EP" % \
		[Globals.ordinal(4), Globals.ordinal(5), Globals.int_to_string(Costs[1][1])]
	
	if is_bought(7):
		$Columns/Col2/Dim36mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCurrently: ×%s" % \
		[Globals.ordinal(3), Globals.ordinal(6), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col2/Dim36mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\nCost: %s EP" % \
		[Globals.ordinal(3), Globals.ordinal(6), Globals.int_to_string(Costs[1][2])]
	
	if is_bought(8):
		$Columns/Col2/GalaxyBoost.text = "Tachyon Galaxies are\ntwice as strong."
	else:
		$Columns/Col2/GalaxyBoost.text = \
		"Tachyon Galaxies are\ntwice as strong.\n \n \nCost: %s EP" % \
		Globals.int_to_string(Costs[1][3])
	
	if is_bought(9):
		$Columns/Col3/AchMult.text = \
		"Achievements give a\nmultiplier to all\nTachyon Dimensions.\n \nCurrently: ×%s" % \
		Formulas.achievement_mult()
	else:
		$Columns/Col3/AchMult.text = \
		"Achievements give a\nmultiplier to all\nTachyon Dimensions.\n \nCost: %s EP" % \
		Globals.int_to_string(Costs[2][0])
	
	if is_bought(10):
		$Columns/Col3/DilaMult.text = \
		"Time Dilation\nmultiplier is increased.\n(×%s → ×%s)" % \
		[Globals.float_to_string(2,1), Globals.float_to_string(2.5,1)]
	else:
		$Columns/Col3/DilaMult.text = \
		"Time Dilation\nmultiplier is increased.\n(×%s → ×%s)\n \nCost: %s EP" % \
		[Globals.float_to_string(2,1), Globals.float_to_string(2.5,1), Globals.int_to_string(Costs[2][1])]
	
	if is_bought(11):
		$Columns/Col3/EPMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on unspent EP.\n \nCurrently: ×%s" % \
		Globals.EternityPts.add(1).to_string()
	else:
		$Columns/Col3/EPMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on unspent EP.\n \nCost: %s EP" % \
		Globals.int_to_string(Costs[2][2])
