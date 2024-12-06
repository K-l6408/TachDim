extends Node

var BoughtUpgrades := 0
var UpgradeCosts := [
	[1, 1, 1, 2], [1, 1, 1, 2], [3, 5, 7, 10], [20, 35, 50, 75], [300]
]
var EPMultBought := 0
var EU12Timer = null

func upgrade_bought(which):
	return ((BoughtUpgrades >> (which - 1)) & 1) == 1

func unbuy(which):
	BoughtUpgrades &= 262143 - \
		1 << (which - 1)

func buy(which):
	var i : int = (which - 1) / 4
	var j : int = (which - 1) % 4
	Currencies.EternityPts.spend(UpgradeCosts[i][j])
	BoughtUpgrades |= 1 << (which - 1)

func buyEPmult():
	Currencies.EternityPts.spend(largenum.ten_to_the(EPMultBought + 1))
	EPMultBought += 1

func maxEPmult():
	while largenum.ten_to_the(EPMultBought + 1).less(Currencies.EternityPts.AMOUNT):
		buyEPmult()

func _process(delta):
	if upgrade_bought(12) \
	and (EU12Timer == null or EU12Timer.time_left == 0) \
	and Globals.fastestEtern.time > 0:
		Currencies.EternityPts.add(Globals.fastestEtern.currency)
		EU12Timer = get_tree().create_timer(Globals.fastestEtern.time * 3)
	
	#if OEUHandler is Node:
		#var avg = largenum.new(0)
		#for i in last10etern:
			#avg.add2self(i.currency.divide(i.time))
		#avg.div2self(last10etern.size())
		#EternityPts.add2self(avg.mult2self(delta * OEUHandler.PasEPBought / 20))
