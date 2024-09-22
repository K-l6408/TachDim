extends Control

var tickFraction := 0.0

func on_eternity():
	if not Globals.Achievemer.is_unlocked(6, 8):
		Globals.Duplicantes = largenum.new(1)

func reset():
	chance = 1
	intervUpgrades = 0
	limitUpgrades = 0
	maxGalaxies = 0
	dupGalaxies = 0

var chance := 1
func buy_chance():
	if chance >= 100: return
	Globals.Duplicantes.div2self(2.0 ** chance)
	if Globals.Duplicantes.exponent < 61:
		Globals.Duplicantes.mantissa >>= 61 - int(Globals.Duplicantes.exponent)
		Globals.Duplicantes.mantissa <<= 61 - int(Globals.Duplicantes.exponent)
	chance += 1

var intervUpgrades := 0
var intervalCap :
	get:
		if "1×2" in Globals.Studies.purchased:
			return 0.05 / 5
		else:
			return 0.05
func interval():
	var interv = 0.9 ** intervUpgrades
	if "1×2" in Globals.Studies.purchased:
		interv /= 5
	if interv <= intervalCap: return intervalCap
	return interv
func buy_interval():
	Globals.Duplicantes.div2self(3.0 ** (intervUpgrades + 1))
	if Globals.Duplicantes.exponent < 61:
		Globals.Duplicantes.mantissa >>= 61 - int(Globals.Duplicantes.exponent)
		Globals.Duplicantes.mantissa <<= 61 - int(Globals.Duplicantes.exponent)
	intervUpgrades += 1

var limitUpgrades := 0
func limit():
	return largenum.two_to_the(2 ** (limitUpgrades + 4))
func limit_cost():
	return largenum.ten_to_the(45 + 15 * limitUpgrades)
func buy_limit():
	Globals.EternityPts.add2self(limit_cost().neg())
	limitUpgrades += 1

var maxGalaxies := 0
func buy_maxgal():
	Globals.EternityPts.add2self(largenum.ten_to_the(140 + 60 * maxGalaxies).neg())
	maxGalaxies += 1

var dupGalaxies := 0
func buy_galaxy():
	Globals.Duplicantes = largenum.new(1)
	if "4×2" not in Globals.Studies.purchased:
		chance = 1
	if "4×1" not in Globals.Studies.purchased:
		intervUpgrades = 0
	dupGalaxies += 1
	Globals.TDHandler.updateTSpeed()

func _process(delta):
	if Globals.progressBL < Globals.Progression.Duplicantes:
		if not Globals.Duplicantes.less(0):
			Globals.Duplicantes = largenum.new(0)
		if Globals.ECCompleted(3):
			if  Globals.progress < Globals.Progression.Duplicantes:
				Globals.progress = Globals.Progression.Duplicantes
			Globals.progressBL   = Globals.Progression.Duplicantes
	elif Globals.Duplicantes.less(1):
		Globals.Duplicantes = largenum.new(1)
	
	$HSplitContainer.split_offset = size.x / 2 - 2
	
	%TextD.text = "[center]You have [font_size=20]%s[/font_size] Duplican%ss,\n" % [
		Globals.Duplicantes.to_string().trim_suffix(".00"),
		"" if Globals.Duplicantes.exponent == 0 else "te"
	] + \
	"giving a [font_size=20]×%s[/font_size] multiplier to all Eternity Dimensions." % \
	(
		Formulas.duplicantes().to_string() if
		Formulas.duplicantes() is largenum else
		Globals.float_to_string(Formulas.duplicantes())
	)
	
	%TextL.text = \
	"[center]You can only hold [font_size=20]%s[/font_size] Duplicantes. (%s)" % [
		limit().to_string(),
		Globals.percent_to_string(Globals.Duplicantes.log2() / limit().log2())
	]
	
	%TextG.text = \
	"[center]You have [font_size=20]%s[/font_size] Duplicantes Galax%s." % [
		Globals.int_to_string(dupGalaxies),
		"y" if dupGalaxies == 1 else "ies"
	]
	
	if Globals.Duplicantes.exponent == -INF:
		%DupGain.text = "You are not gaining any Duplicantes."
	else:
		var about = ""
		if chance < 100:
			if   Globals.Duplicantes.log10() < 1:
				about = "Approximately "
			elif Globals.Duplicantes.log10() < 1.5:
				about = "Approx. "
			elif Globals.Duplicantes.log10() < 2:
				about = "About "
			elif Globals.Duplicantes.log10() < 2.5:
				about = "Abt "
			elif Globals.Duplicantes.log10() < 3:
				about = "~"
		%DupGain.text = "You are gaining ×%s Duplicantes per second. (%s%s to reach the limit)" % [
			largenum.new(chance / 100. + 1).power(1. / interval()),
			about, Globals.format_time(
				limit().divide(Globals.Duplicantes).log2() \
				* 100 * interval() / chance
			)
		]
	
	if limitUpgrades >= 6:
		%Limit.text = "Duplicantes limit:\n%s (capped)" % \
		limit().to_string()
	else:
		%Limit.text = "Square Duplicantes\nlimit (%s → %s)\nCost: %s EP" % [
			limit().to_string(), limit().power(2).to_string(),
			limit_cost().to_string().replace(".00", "")
		]
	%Limit.disabled = Globals.EternityPts.less(limit_cost()) or limitUpgrades >= 6
	
	%MaxGal.text = "Max Duplicantes\nGalaxies: %s\nCost: %s EP" % [
		Globals.int_to_string(maxGalaxies),
		largenum.ten_to_the(140 + 60 * maxGalaxies).to_string().replace(".00", "")
	]
	%MaxGal.disabled = Globals.EternityPts.less(
		largenum.ten_to_the(140 + 60 * maxGalaxies)
	)
	
	if "4×1" in Globals.Studies.purchased and "4×2" in Globals.Studies.purchased:
		%Galaxy.text = "Reset Duplicantes to %s\nfor a Duplicantes" % \
		Globals.int_to_string(1) + \
		" Galaxy\n(Requires %s Duplicantes\nand maxed out upgrades)" % \
		largenum.two_to_the(1024).to_string()
	elif "4×1" in Globals.Studies.purchased:
		%Galaxy.text = "Reset Duplicantes and Duplicantes Chance Upgrades\nfor a Duplicantes" + \
		" Galaxy\n(Requires %s Duplicantes\nand maxed out upgrades)" % \
		largenum.two_to_the(1024).to_string()
	elif "4×2" in Globals.Studies.purchased:
		%Galaxy.text = "Reset Duplicantes and Duplicantes Interval Upgrades\nfor a Duplicantes" + \
		" Galaxy\n(Requires %s Duplicantes\nand maxed out upgrades)" % \
		largenum.two_to_the(1024).to_string()
	else:
		%Galaxy.text = "Reset Duplicantes and Duplicantes Upgrades\nfor a Duplicantes" + \
		" Galaxy\n(Requires %s Duplicantes\nand maxed out upgrades)" % \
		largenum.two_to_the(1024).to_string()
	%Galaxy.disabled = (
		Globals.Duplicantes.log2() < 1024 or chance < 100
		or interval() < intervalCap or dupGalaxies >= maxGalaxies
	)
	
	tickFraction += delta / interval()
	if limit().less(Globals.Duplicantes):
		Globals.Duplicantes = limit()
	elif tickFraction >= 1:
		if chance == 100:
			Globals.Duplicantes.exponent += floor(tickFraction)
		elif tickFraction > 10000 or Globals.Duplicantes.log10() > 3:
			Globals.Duplicantes.mult2self(
				largenum.new(chance / 100.0 + 1).power(floor(tickFraction))
			)
		else:
			for d in int(Globals.Duplicantes.to_float()):
				for t in int(tickFraction):
					if randi_range(1, 100) <= chance:
						Globals.Duplicantes.add2self(1)
		if limit().less(Globals.Duplicantes):
			Globals.Duplicantes = limit()
	
	tickFraction = fmod(tickFraction, 1.0)
	
	%Chance.disabled   = Globals.Duplicantes.less(2.0 ** chance - 0.001) or chance >= 100
	%Interval.disabled = Globals.Duplicantes.less(3.0 ** (intervUpgrades + 1) - 0.001) or \
	interval() <= intervalCap
	
	if chance >= 100:
		%Chance.text = "Duplication chance:\n%s (capped)" % [
			Globals.percent_to_string(chance / 100.0, 0),
		]
	else:
		%Chance.text = "Improve Duplication\nchance (%s → %s)\nCost: /%s Dupl." % [
			Globals.percent_to_string(chance / 100.0       , 0),
			Globals.percent_to_string(chance / 100.0 + 0.01, 0),
			Globals.int_to_string(2 ** chance) if 2.0**chance < 1e5 else
			Globals.float_to_string(2.0 ** chance)
		]
	
	if interval() <= intervalCap:
		%Interval.text = "Duplication interval:\n%s (capped)" % \
		Globals.format_time(interval())
	else:
		%Interval.text = "Improve Duplication\ninterval (%s → %s)" % [
			Globals.format_time(interval()),
			Globals.format_time(max(interval() * 0.9, intervalCap))
		] + \
		"\nCost: /%s Dupl." % (
			Globals.int_to_string(3 ** (intervUpgrades + 1)) if
			3.0 ** (intervUpgrades + 1) < 1e5 else
			Globals.float_to_string(3.0 ** (intervUpgrades + 1))
		)
