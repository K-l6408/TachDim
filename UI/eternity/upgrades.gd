extends Control

func buy(which):
	Eternity.buy(which) # TODO: remove ðis??

func _process(_delta):
	for i in $Columns.get_child_count():
		var k = $Columns.get_child(i)
		for j in k.get_child_count():
			if not k.get_child(j) is Button:
				if k.get_child(j) is Line2D:
					var L : Line2D = k.get_child(j)
					for q in 4:
						if Eternity.upgrade_bought(i*4+q+1):
							L.gradient.colors[q + 1] = get_theme_color("font_color", "ButtonEtern")
						else:
							L.gradient.colors[q + 1] = get_theme_color("disabled_color", "ButtonEtern")
					L.gradient.colors[0] = L.gradient.colors[1]
					L.gradient.colors[5] = L.gradient.colors[4]
				continue
			
			if Eternity.upgrade_bought(i*4+j+1):
				k.get_child(j).disabled = true
				k.get_child(j).add_theme_stylebox_override("disabled", \
				get_theme_stylebox("enabled", "ButtonEtern"))
				continue
			else:
				k.get_child(j).remove_theme_stylebox_override("disabled")
				k.get_child(j).disabled = \
				Eternity.UpgradeCosts[i][j] > \
				Currencies.EternityPts.AMOUNT.to_float()
				if j > 0 and not Eternity.upgrade_bought(i*4+j):
					k.get_child(j).disabled = true
	
	$AutoGal   .visible = Globals.Achievemer.is_unlocked(4, 6)
	$EPMult    .visible = Globals.Achievemer.is_unlocked(4, 6)
	$EPMult/Max.visible = Globals.Achievemer.is_unlocked(4, 6)
	if Globals.Achievemer.is_unlocked(4, 6):
		custom_minimum_size.y = 610
	else:
		custom_minimum_size.y = 470
	
	if Eternity.upgrade_bought(17):
		$AutoGal.disabled = true
		$AutoGal.add_theme_stylebox_override("disabled", \
		get_theme_stylebox("enabled", "ButtonEtern"))
	else:
		$AutoGal.remove_theme_stylebox_override("disabled")
		$AutoGal.disabled = Currencies.EternityPts.AMOUNT.less(Eternity.UpgradeCosts[4][0])
	
	$EPMult.disabled = not \
	largenum.ten_to_the(Eternity.EPMultBought + 1).\
	less(Currencies.EternityPts.AMOUNT)
	$EPMult/Max.disabled = not \
	largenum.ten_to_the(Eternity.EPMultBought + 1).\
	less(Currencies.EternityPts.AMOUNT)
	
	# TODO: move to autobuyers.gd
	#if Globals.Automation.EPMultEnabled and \
	#largenum.ten_to_the(Eternity.EPMultBought + 1).\
	#less(Currencies.EternityPts.AMOUNT):
		#Eternity.maxEPmult()
	
	if Eternity.upgrade_bought(1) != Input.is_action_pressed("BuyOne"):
		$Columns/Col1/TimePlayed.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on time spent\nin this Eternity.\n \nCurrently: ×%s" % \
		Globals.float_to_string(Formulas.eternity_11())
	else:
		$Columns/Col1/TimePlayed.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on time spent\nin this Eternity.\n \nCost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[0][0])
	
	if Eternity.upgrade_bought(2) != Input.is_action_pressed("BuyOne"):
		$Columns/Col1/Dim18mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCurrently: ×%s" % \
		[Globals.ordinal(1), Globals.ordinal(8), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col1/Dim18mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCost: %s EP" % \
		[Globals.ordinal(1), Globals.ordinal(8), Globals.int_to_string(Eternity.UpgradeCosts[0][1])]
	
	if Eternity.upgrade_bought(3) != Input.is_action_pressed("BuyOne"):
		$Columns/Col1/Dim27mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCurrently: ×%s" % \
		[Globals.ordinal(2), Globals.ordinal(7), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col1/Dim27mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCost: %s EP" % \
		[Globals.ordinal(2), Globals.ordinal(7), Globals.int_to_string(Eternity.UpgradeCosts[0][2])]
	
	if Eternity.upgrade_bought(4) != Input.is_action_pressed("BuyOne"):
		$Columns/Col1/DGCheaper.text = \
		"Dilation and Galaxies\nare cheaper by\n%s and %s Dimensions,\nrespectively." % \
		[Globals.int_to_string(5), Globals.int_to_string(10)]
	else:
		$Columns/Col1/DGCheaper.text = \
		"Dilation and Galaxies\nare cheaper by\n%s and %s Dimensions,\nrespectively.\n\nCost: %s EP" % \
		[Globals.int_to_string(5), Globals.int_to_string(10), Globals.int_to_string(Eternity.UpgradeCosts[0][3])]
	
	if Eternity.upgrade_bought(5) != Input.is_action_pressed("BuyOne"):
		$Columns/Col2/MultIncrease.text = \
		"Increase the multiplier\nfor buying %s\nTachyon Dimensions.\n\n\n(×%s → ×%s)" % \
		[Globals.int_to_string(10),
		Globals.float_to_string(2), Globals.float_to_string(2.22222)]
	else:
		$Columns/Col2/MultIncrease.text = \
		"Increase the multiplier\nfor buying %s\nTachyon Dimensions.\n\n\nCost: %s EP" % \
		[Globals.int_to_string(10),
		Globals.int_to_string(Eternity.UpgradeCosts[1][0])]
	
	if Eternity.upgrade_bought(6) != Input.is_action_pressed("BuyOne"):
		$Columns/Col2/Dim45mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCurrently: ×%s" % \
		[Globals.ordinal(4), Globals.ordinal(5), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col2/Dim45mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCost: %s EP" % \
		[Globals.ordinal(4), Globals.ordinal(5), Globals.int_to_string(Eternity.UpgradeCosts[1][1])]
	
	if Eternity.upgrade_bought(7) != Input.is_action_pressed("BuyOne"):
		$Columns/Col2/Dim36mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCurrently: ×%s" % \
		[Globals.ordinal(3), Globals.ordinal(6), Formulas.eternity_23().to_string()]
	else:
		$Columns/Col2/Dim36mult.text = \
		"%s and %s\nTachyon Dimensions\nget a multiplier\nbased on Eternities.\n\nCost: %s EP" % \
		[Globals.ordinal(3), Globals.ordinal(6), Globals.int_to_string(Eternity.UpgradeCosts[1][2])]
	
	if Eternity.upgrade_bought(8) != Input.is_action_pressed("BuyOne"):
		$Columns/Col2/GalaxyBoost.text = "All Galaxies are\ntwice as strong."
	else:
		$Columns/Col2/GalaxyBoost.text = \
		"\nAll Galaxies are\ntwice as strong.\n \n \nCost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[1][3])
	
	if Eternity.upgrade_bought(9) != Input.is_action_pressed("BuyOne"):
		$Columns/Col3/AchMult.text = \
		"Achievements give a\nmultiplier to all\nTachyon Dimensions.\n\n\nCurrently: ×%s" % \
		Formulas.achievement_mult()
	else:
		$Columns/Col3/AchMult.text = \
		"Achievements give a\nmultiplier to all\nTachyon Dimensions.\n\n\nCost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[2][0])
	
	if Eternity.upgrade_bought(10) != Input.is_action_pressed("BuyOne"):
		$Columns/Col3/DilaMult.text = \
		"\nTime Dilation\nmultiplier is increased.\n\n\n(×%s → ×%s)" % \
		[Globals.float_to_string(2,1), Globals.float_to_string(2.5,1)]
	else:
		$Columns/Col3/DilaMult.text = \
		"\nTime Dilation\nmultiplier is increased.\n\n\nCost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[2][1])
	
	if Eternity.upgrade_bought(11) != Input.is_action_pressed("BuyOne"):
		$Columns/Col3/EPMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on unspent EP.\n\n\nCurrently: ×%s" % \
		Currencies.EternityPts.AMOUNT.add(1).to_string()
	else:
		$Columns/Col3/EPMult.text = \
		"Tachyon Dimensions\nget a multiplier\nbased on unspent EP.\n\n\nCost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[2][2])
	
	$Columns/Col3/PassiveEP.text = \
	"You gain Eternity Points\npassively %s times\nslower than your\nfastest Eternity.\n\n" % \
	Globals.int_to_string(3)
	if Eternity.upgrade_bought(12) != Input.is_action_pressed("BuyOne"):
		if Globals.fastestEtern.time < 0:
			$Columns/Col3/PassiveEP.text += "Currently: Too slow\nto generate"
		else:
			$Columns/Col3/PassiveEP.text += "Currently: %s\nevery %s" % \
			[Globals.fastestEtern.currency, Globals.format_time(Globals.fastestEtern.time * 3)]
	else:
		$Columns/Col3/PassiveEP.text += "Cost: %s EP" % \
		Globals.int_to_string(Eternity.UpgradeCosts[2][3])
	
	for i in 4:
		if Eternity.upgrade_bought(13 + i) != Input.is_action_pressed("BuyOne"):
			$Columns/Col4.get_child(i).text = \
			"Start every reset with %s\nDilation," % Globals.int_to_string(i + 1) + \
			" automatically\nunlocking the %s\nTachyon Dimension." % Globals.ordinal(i + 5)
		else:
			$Columns/Col4.get_child(i).text = \
			"Start every reset with %s\nDilation," % Globals.int_to_string(i + 1) + \
			" automatically\nunlocking the %s\nTachyon Dimension.\n" % Globals.ordinal(i + 5) + \
			"\nCost: %s EP" % Globals.int_to_string(Eternity.UpgradeCosts[3][i])
	
	$AutoGal.text = "%s %s\n%s\n%s\n%s" % [
		"Start every reset with", Globals.int_to_string(5), "Dilation, automatically",
		"unlocking Rewind, and", "a Tachyon Galaxy."
	]
	if Eternity.upgrade_bought(17) == Input.is_action_pressed("BuyOne"):
		$AutoGal.text += "\n\nCost: %s EP" % Globals.int_to_string(Eternity.UpgradeCosts[4][0])
	
	$EPMult.text = \
	"Multiply EP gained from\nBig Bangs by %s.\n\nCurrently: ×%s\n\nCost: %s EP" % [
		Globals.int_to_string(2), largenum.new(2).power(Eternity.EPMultBought),
		largenum.ten_to_the(Eternity.EPMultBought + 1)
	]
