extends Node

var tickFraction := 0.0

func on_permanence():
	if not Globals.Achievemer.is_unlocked(6, 8):
		Currencies.Duplicantes.reset()
		dupGalaxies = 0
	if dupGalaxies > 5:
		dupGalaxies = 5

func reset():
	chance = 1
	intervUpgrades = 0
	limitUpgrades = 0
	maxGalaxies = 0
	dupGalaxies = 0

var chance := 1
func chance_cost():
	return 2.0 ** chance
func buy_chance():
	if chance >= 100: return
	if Currencies.Duplicantes.spend(chance_cost()):
		chance += 1

var intervUpgrades := 0
var intervalCap :
	get:
		#if "7×1" in Globals.Studies.purchased:
			#if "1×2" in Globals.Studies.purchased:
				#return 0.001
			#else:
				#return 0.005
		#if "1×2" in Globals.Studies.purchased:
			#return 0.01
		#else:
		return 0.01
func interval(upgr := intervUpgrades):
	var interv = 0.9 ** upgr
	if "1×2" in Globals.Studies.purchased:
		interv /= 5
	if interv <= intervalCap: return intervalCap
	return interv
func interval_cost():
	return 3.0 ** (intervUpgrades + 1)
func buy_interval():
	if interval() <= intervalCap: return
	if Currencies.Duplicantes.spend(interval_cost()):
		intervUpgrades += 1

var limitUpgrades := 0
func limit():
	return largenum.two_to_the(2 ** (limitUpgrades + 4))
func limit_cost():
	return largenum.ten_to_the(30 + 15 * limitUpgrades)
func buy_limit():
	if Currencies.PermanencePts.spend(limit_cost()):
		limitUpgrades += 1

var maxGalaxies := 0
func maxgal_cost():
	return largenum.ten_to_the(140 + maxGalaxies * (50 + 5 * maxGalaxies))
func buy_maxgal():
	if Currencies.PermanencePts.spend(maxgal_cost()):
		maxGalaxies += 1

var dupGalaxies := 0
func buy_galaxy():
	Currencies.Duplicantes.reset()
	dupGalaxies += 1
	chance = dupGalaxies * 2 + 1
	intervUpgrades = dupGalaxies * 2

func _process(delta):
	if Globals.progressBL < Globals.Progression.Duplicantes:
		if not Currencies.Duplicantes.AMOUNT.less(0):
			Currencies.Duplicantes.AMOUNT = largenum.new(0)
		if Globals.ECCompleted(3):
			if  Globals.progress < Globals.Progression.Duplicantes:
				Globals.progress = Globals.Progression.Duplicantes
			Globals.progressBL   = Globals.Progression.Duplicantes
	elif Currencies.Duplicantes.AMOUNT.less(1):
		Currencies.Duplicantes.reset()
	
	tickFraction += delta / interval()
	if tickFraction >= 1:
		if chance == 100:
			Currencies.Duplicantes.multiply(largenum.two_to_the(floor(tickFraction)))
		elif tickFraction > 10000 or Currencies.Duplicantes.AMOUNT.log10() > 3:
			Currencies.Duplicantes.multiply(
				largenum.new(chance / 100.0 + 1).power(floor(tickFraction))
			)
		else:
			for d in int(Currencies.Duplicantes.AMOUNT.to_float()):
				for t in int(tickFraction):
					if randi_range(1, 100) <= chance:
						Currencies.Duplicantes.add(1)
		if limit().less(Currencies.Duplicantes.AMOUNT):
			Currencies.Duplicantes.AMOUNT = limit()
	
	tickFraction = fmod(tickFraction, 1.0)
