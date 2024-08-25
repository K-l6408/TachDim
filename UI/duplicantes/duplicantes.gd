extends Control

var tickFraction := 0.0

var chance := 1
func buy_chance():
	Globals.Duplicantes.div2self(2 ** chance)
	if Globals.Duplicantes.exponent < 61:
		Globals.Duplicantes.mantissa >>= 61 - int(Globals.Duplicantes.exponent)
		Globals.Duplicantes.mantissa <<= 61 - int(Globals.Duplicantes.exponent)
	chance += 1

var intervUpgrades := 0
func interval():
	return max(0.9 ** intervUpgrades, 0.01)
func buy_interval():
	Globals.Duplicantes.div2self(3 ** (intervUpgrades + 1))
	if Globals.Duplicantes.exponent < 61:
		Globals.Duplicantes.mantissa >>= 61 - int(Globals.Duplicantes.exponent)
		Globals.Duplicantes.mantissa <<= 61 - int(Globals.Duplicantes.exponent)
	intervUpgrades += 1

var limitUpgrades := 0
func limit():
	return largenum.two_to_the(2 ** (limitUpgrades + 4))

var maxGalaxies := 0

var dupGalaxies := 0

func _process(delta):
	if Globals.progress < Globals.Progression.Duplicantes:
		if Globals.ECCompleted(3):
			Globals.progress = Globals.Progression.Duplicantes
		else: return
	
	$HSplitContainer.split_offset = size.x / 2 - 2
	
	%TextD.text = "[center]You have [font_size=20]%s[/font_size] Duplican%ss,\n" % [
		Globals.Duplicantes.to_string().trim_suffix(".00"),
		"te" if Globals.Duplicantes.to_float() > 1 else ""
	] + \
	"giving a [font_size=20]×%s[/font_size] multiplier to all Eternity Dimensions." % \
	Globals.float_to_string(Formulas.duplicantes())
	
	%TextL.text = \
	"[center]You can only hold [font_size=20]%s[/font_size] Duplicantes. (%s)" % [
		limit().to_string(),
		Globals.percent_to_string(Globals.Duplicantes.log2() / limit().log2())
	]
	
	tickFraction += delta / interval()
	if tickFraction >= 1 and not limit().less(Globals.Duplicantes):
		if tickFraction > 10000 or Globals.Duplicantes.log10() > 3:
			Globals.Duplicantes.mult2self(
				largenum.new(chance / 100.0 + 1).power(floor(tickFraction))
			)
			if limit().less(Globals.Duplicantes):
				Globals.Duplicantes = limit()
		else:
			for t in int(tickFraction) * int(Globals.Duplicantes.to_float()):
				if randi_range(1, 100) <= chance:
					Globals.Duplicantes.add2self(1)
	
	tickFraction = fmod(tickFraction, 1.0)
	
	%Chance.disabled   = Globals.Duplicantes.less(2 ** chance - 0.001) or chance >= 100
	%Interval.disabled = Globals.Duplicantes.less(3 ** (intervUpgrades + 1) - 0.001) or \
	interval() <= 0.01
	
	%Chance.text = "Improve Duplication\nchance (%s → %s)\nCost: /%s Dupl." % [
		Globals.percent_to_string(chance / 100.0       , 0),
		Globals.percent_to_string(chance / 100.0 + 0.01, 0),
		Globals.int_to_string(2 ** chance)
	]
	%Interval.text = "Improve Duplication\ninterval (%s → %s)" % \
	[Globals.format_time(interval()), Globals.format_time(interval() * 0.9)] + \
	"\nCost: /%s Dupl." % Globals.int_to_string(3 ** (intervUpgrades + 1))
