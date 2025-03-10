extends Node

var BoughtUpgrades := 0
var OvercomeUpgrades := 0
var UpgradeCosts := [
	[1, 1, 1, 2], [1, 1, 1, 2], [3, 5, 7, 10], [20, 35, 50, 75], [300]
]
var OvercomeCosts := [
	1e3, 1e6, 1e9,
	3e6, 1e4, 4e4,
	1e5, 2e8, 3e5
]
var PPMultBought := 0
var PU12Timer = 0
var TSpScBought := 0
var TDmScBought := 0
var PasPPBought := 0

func upgrade_bought(which):
	return ((BoughtUpgrades >> (which - 1)) & 1) == 1

func overcome_upgrade_bought(which):
	return ((OvercomeUpgrades >> (which - 1)) & 1) == 1

func buy(which):
	var i : int = (which - 1) / 4
	var j : int = (which - 1) % 4
	if Currencies.PermanencePts.spend(UpgradeCosts[i][j]):
		BoughtUpgrades |= 1 << (which - 1)
func unbuy(which):
	BoughtUpgrades &= (1 << 12 - 1) - \
		1 << (which - 1)

func buy_over(which):
	if Currencies.PermanencePts.spend(OvercomeCosts[which - 1]):
		OvercomeUpgrades |= 1 << (which - 1)
func unbuy_over(which):
	OvercomeUpgrades &= (1 << 9 - 1) - \
		1 << (which - 1)

func tspsc_cost():
	return largenum.ten_to_the(4   + 1.5     * TSpScBought)
func tdmsc_cost():
	return largenum.ten_to_the(4.5 + 2.33333 * TDmScBought)
func paspp_cost():
	return largenum.ten_to_the(5   + 0.66666 * PasPPBought)

func buy_rebuyable(which):
	match which:
		1:
			if Currencies.PermanencePts.spend(tspsc_cost()):
				TSpScBought += 1
		2:
			if Currencies.PermanencePts.spend(tdmsc_cost()):
				TDmScBought += 1
		3:
			if Currencies.PermanencePts.spend(paspp_cost()):
				PasPPBought += 1

func buyPPmult():
	if Currencies.PermanencePts.spend(largenum.ten_to_the(PPMultBought + 1)):
		PPMultBought += 1

func maxPPmult():
	PPMultBought += floor(
		Currencies.PermanencePts.AMOUNT.divide(largenum.ten_to_the(PPMultBought + 1)).log10()
	) - 15 # cost too small for ðe purchase to actually matter. also saves performance!
	while largenum.ten_to_the(PPMultBought + 1).less(Currencies.PermanencePts.AMOUNT):
		buyPPmult()

func _process(delta):
	if upgrade_bought(12):
		if (PU12Timer <= 0) \
		and Globals.fastestEtern.time > 0:
			Currencies.PermanencePts.add(Globals.fastestEtern.currency)
			PU12Timer += (Globals.fastestEtern.time * 3)
		elif PU12Timer > (Globals.fastestEtern.time * 3):
			PU12Timer = (Globals.fastestEtern.time * 3)
		PU12Timer -= delta
	
	#if OEUHandler is Node:
		#var avg = largenum.new(0)
		#for i in last10etern:
			#avg.add2self(i.currency.divide(i.time))
		#avg.div2self(last10etern.size())
		#PermanencePts.add2self(avg.mult2self(delta * OEUHandler.PasEPBought / 20))
	
	process_pp_gain()

func process_pp_gain():
	#if "3×2" in Globals.Studies.purchased:
		#epgain.mult2self(1.5 ** Globals.TGalaxies)
	#
	#epgain.integerize()
	#
	#return epgain
	
	var ppgain = largenum.new(1)
	Currencies.PermanencePts.mults = {}
	
	Currencies.PermanencePts.mults["Base gain from Tachyons"] = null
	
	if overcome_upgrade_bought(4):
		Currencies.PermanencePts.mults["Base gain from Tachyons"] = \
		Currencies.Multiplier.new(largenum.five_to_the((
			TachyonDims.topTachyonsInPermanence.log2() / 900
		) - 1))
		
		ppgain.mult2self(largenum.five_to_the((
			TachyonDims.topTachyonsInPermanence.log2() / 900
		) - 1))
	else:
		Currencies.PermanencePts.mults["Base gain from Tachyons"] = \
		Currencies.Multiplier.new(largenum.five_to_the((
			TachyonDims.topTachyonsInPermanence.log2() / 1024
		) - 1))
		
		ppgain.mult2self(largenum.five_to_the((
			TachyonDims.topTachyonsInPermanence.log2() / 1024
		) - 1))
	
	Currencies.PermanencePts.mults["Repeatable ×2 multiplier"] = \
	Currencies.Multiplier.new(largenum.two_to_the(PPMultBought))
	ppgain.mult2self(largenum.two_to_the(PPMultBought))
	
	return ppgain
