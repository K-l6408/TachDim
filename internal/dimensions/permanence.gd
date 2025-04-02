extends Node

var DimAmount : Array[largenum] = [
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
]
var DimPurchase : Array[int] = [0,0,0,0,0,0,0,0]

var Multipliers : Array[largenum] = [
	largenum.new(1),largenum.new(1),largenum.new(1),largenum.new(1),
	largenum.new(1),largenum.new(1),largenum.new(1),largenum.new(1)
]

const TachLogReq := [
	1000,  1400,  4000,  9400,
	18000, 26000, 42000, 80000.903
]

var DimsUnlocked := 0
var TSperS       := largenum.new(0)
var TimeShards   := largenum.new(0)
var FreeTSpeed   := 0
var NextUpgrade  := largenum.new(0.1)
var TreshMult    : float : 
	get:
		if Globals.Challenge == 21:
			return .09 + 1.01 ** FreeTSpeed
		#if FreeTSpeed > 4000:
			#if Globals.ECCompleted(6):
				#return 4.375
			#return 5.0
		#if FreeTSpeed > 500:
			#if Globals.ECCompleted(6):
				#return 1.75
			#return 2.0
		if Globals.ECCompleted(5):
			return 1.9
		return 2.0

func dimcost(which):
	var start = [
		4, 6, 15, 30, 45, 70, 130, 200
	][which-1]
	var increase = [
		3, 5, 8, 15, 20, 25, 30, 35
	][which-1]
	return largenum.ten_to_the(start + increase * DimPurchase[which-1])

func buydim(which):
	if which > DimsUnlocked: return
	if Currencies.PermanencePts.spend(dimcost(which)):
		DimPurchase[which-1] += 1
		DimAmount[which-1].add2self(10)

func buymax():
	for i in DimsUnlocked:
		while dimcost(DimsUnlocked - i).less(Currencies.PermanencePts.AMOUNT):
			buydim(DimsUnlocked - i)

func eternitied():
	TimeShards = largenum.new(0)
	FreeTSpeed = 0
	NextUpgrade = largenum.new(0.1)
	for i in 8:
		DimAmount[i] = largenum.new(DimPurchase[i] * 10)

func unlocknewdim():
	if Currencies.Tachyons.AMOUNT.log10() >= TachLogReq[DimsUnlocked]:
		DimsUnlocked += 1

func reset():
	for i in 8:
		DimPurchase[i] = 0
	eternitied()
	DimsUnlocked = 0

func _process(delta: float) -> void:
	while not TimeShards.less(NextUpgrade):
		NextUpgrade.mult2self(TreshMult)
		FreeTSpeed += 1
	
	var buymult = [32, 16, 8, 4, 2, 2, 2, 2]
	
	for i in range(1, min(DimsUnlocked+1, 8)):
		var mult := largenum.new(1)
		
		mult.mult2self(largenum.new(buymult[i-1]).power(DimPurchase[i-1]))
		
		if Globals.Challenge == 20:
			mult.pow2self(1.1)
		
		if Globals.progressBL >= GL.Progression.Duplicantes:
			mult.mult2self(Formulas.duplicantes())
		
		if "Time1" in Globals.Studies.purchased:
			mult.mult2self(Formulas.study_time1())
		
		if Globals.ECCompleted(2) and i <= 4:
			mult.mult2self(Formulas.ec2_reward())
		
		Multipliers[i-1] = mult
		
		if i == 1:
			TSperS = DimAmount[i-1].multiply(mult)
			TimeShards.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
		else:
			DimAmount[i-2].add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
