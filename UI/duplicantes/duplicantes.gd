extends Control

func _ready() -> void:
	%Chance.connect("pressed", Duplicantes.buy_chance)
	%Interval.connect("pressed", Duplicantes.buy_interval)
	%Limit.connect("pressed", Duplicantes.buy_limit)
	%MaxGal.connect("pressed", Duplicantes.buy_maxgal)
	%Galaxy.connect("pressed", Duplicantes.buy_galaxy)

func _process(_delta):
	$HSplitContainer.split_offset = size.x / 2 - 2
	
	%TextD.text = "[center]You have [font_size=20]%s[/font_size] Duplican%ss,\n" % [
		Currencies.Duplicantes.AMOUNT.to_string().trim_suffix(".00").trim_suffix(";00"),
		"" if Currencies.Duplicantes.AMOUNT.exponent == 0 else "te"
	] + \
	"giving a [font_size=20]%s[/font_size] multiplier to all Permanence Dimensions." % \
	(
		Formulas.duplicantes().display(0)
	)
	
	%TextL.text = \
	"[center]You can only hold [font_size=20]%s[/font_size] Duplicantes. (%s)" % [
		Duplicantes.limit().to_string(),
		Globals.percent_to_string(
			Currencies.Duplicantes.AMOUNT.log2() / Duplicantes.limit().log2()
		)
	]
	
	%TextG.text = \
	"[center]You have [font_size=20]%s[/font_size] Duplicantes Galax%s." % [
		Globals.int_to_string(Duplicantes.dupGalaxies),
		"y" if Duplicantes.dupGalaxies == 1 else "ies"
	]
	
	if Currencies.Duplicantes.AMOUNT.exponent == -INF:
		%DupGain.text = "You are not gaining any Duplicantes."
	else:
		var about = ""
		if Duplicantes.chance < 100:
			if   Currencies.Duplicantes.AMOUNT.log10() < 1:
				about = "Approximately "
			elif Currencies.Duplicantes.AMOUNT.log10() < 1.5:
				about = "Approx. "
			elif Currencies.Duplicantes.AMOUNT.log10() < 2:
				about = "About "
			elif Currencies.Duplicantes.AMOUNT.log10() < 2.5:
				about = "Abt "
			elif Currencies.Duplicantes.AMOUNT.log10() < 3:
				about = "~"
		%DupGain.text = "You are gaining ×%s Duplicantes per second. (%s%s to reach the limit)" % [
			largenum.new(Duplicantes.chance / 100. + 1).power(1. / Duplicantes.interval()),
			about, Globals.format_time(
				Duplicantes.limit().divide(Currencies.Duplicantes.AMOUNT).log2() \
				* 100 * Duplicantes.interval() / Duplicantes.chance
			)
		]
	
	if Duplicantes.limitUpgrades >= 6:
		%Limit.text = "Duplicantes limit:\n%s (capped)" % \
		Duplicantes.limit().to_string()
	else:
		%Limit.text = "Square Duplicantes limit\n(%s → %s)\nCost: %s PP" % [
			Duplicantes.limit().to_string(),
			Duplicantes.limit().power(2).to_string(),
			Duplicantes.limit_cost().to_string().replace(".00", "")
		]
	%Limit.disabled = \
		Currencies.PermanencePts.AMOUNT.less(Duplicantes.limit_cost()) or \
		Duplicantes.limitUpgrades >= 6
	
	%MaxGal.text = "Max Duplicantes\nGalaxies: %s\nCost: %s PP" % [
		Globals.int_to_string(Duplicantes.maxGalaxies),
		Duplicantes.maxgal_cost().to_string().replace(".00", "")
	]
	%MaxGal.disabled = Currencies.PermanencePts.AMOUNT.less(
		Duplicantes.maxgal_cost()
	)
	
	%Galaxy.text = "Reset Duplicantes and Duplicantes Upgrades for a " + \
		"Duplicantes Galaxy\n(Requires %s Duplicantes and maxed out upgrades)"\
		% largenum.two_to_the(1024).to_string()
	%Galaxy.disabled = (
		Currencies.Duplicantes.AMOUNT.log2() < 1024 or Duplicantes.chance < 100
		or Duplicantes.interval() < Duplicantes.intervalCap
		or Duplicantes.dupGalaxies >= Duplicantes.maxGalaxies
	)
	
	%Galaxy/Label.text = "%s %s %s\n%s %s %s" % [
		"You can only keep", Globals.int_to_string(5),
		"Duplicantes Galaxies after Big Bangs.",
		"Each time you reset your Duplicantes Upgrades, you keep",
		Globals.int_to_string(2),  "more of them.",
	]
	
	%Chance.disabled = \
		Currencies.Duplicantes.AMOUNT.less(Duplicantes.chance_cost()) \
		or Duplicantes.chance >= 100
	
	%Interval.disabled = \
		Currencies.Duplicantes.AMOUNT.less(Duplicantes.interval_cost()) \
		or Duplicantes.interval() <= Duplicantes.intervalCap
	
	
	if %Galaxy.is_hovered():
		%Chance.text = "Duplication chance:\n%s (→ %s)" % [
			Globals.percent_to_string(Duplicantes.chance / 100.0, 0),
			Globals.percent_to_string(
				(Duplicantes.dupGalaxies + 1) * 0.02 + 0.01, 0
			)
		]
	elif Duplicantes.chance >= 100:
		%Chance.text = "Duplication chance:\n%s (capped)" % [
			Globals.percent_to_string(Duplicantes.chance / 100.0, 0),
		]
	else:
		%Chance.text = "Improve Duplication\nchance (%s → %s)\nCost: /%s Dupl." % [
			Globals.percent_to_string(Duplicantes.chance / 100.0       , 0),
			Globals.percent_to_string(Duplicantes.chance / 100.0 + 0.01, 0),
			Globals.int_to_string(Duplicantes.chance_cost())
				if Duplicantes.chance_cost() < 1e5 else
			Globals.float_to_string(Duplicantes.chance_cost())
		]
	
	if %Galaxy.is_hovered():
		%Interval.text = "Duplication interval:\n%s (→ %s)" % [
			Globals.format_time(Duplicantes.interval()),
			Globals.format_time(Duplicantes.interval(
				(Duplicantes.dupGalaxies + 1) * 2
			))
		]
	elif Duplicantes.interval() <= Duplicantes.intervalCap:
		%Interval.text = "Duplication interval:\n%s (capped)" % \
		Globals.format_time(Duplicantes.interval())
	else:
		%Interval.text = "Improve Duplication\ninterval (%s → %s)" % [
			Globals.format_time(Duplicantes.interval()),
			Globals.format_time(Duplicantes.interval(Duplicantes.intervUpgrades + 1))
		] + \
		"\nCost: /%s Dupl." % (
			Globals.int_to_string(Duplicantes.interval_cost())
				if Duplicantes.interval_cost() < 1e5 else
			Globals.float_to_string(Duplicantes.interval_cost())
		)
