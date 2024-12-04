extends Node

var DimAmount : Array[largenum] = [
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
]
var DimPurchase : Array[int] = [0,0,0,0,0,0,0,0]
const TSpeedScaleStart := 305

var DistantScaling :
	get: return 75

var TSpeedBoost :
	get:
		var GalaxyBoost = 0.975
		var GalaxyMult = 1
		
		if Globals.EUHandler.is_bought(8): GalaxyMult *= 2
		if Globals.OEUHandler.is_bought(3): GalaxyMult *= 1.4
		if Globals.ECCompleted(4): GalaxyMult *= 1.15
		
		TSpeedBoost = \
		largenum.new(1.10 if Globals.Challenge == 12 else 1.13 ).\
		div2self(largenum.new(GalaxyBoost).power(
			(Globals.TGalaxies + Globals.DupHandler.dupGalaxies) * GalaxyMult
		))
var TSpeedCount := 0

var DimsUnlocked := 4

var buylim : int :
	get:
		if Globals.Challenge == 5 or Globals.Challenge == 16:	return 15
		else:													return 10
var latest_purchased = 1

var C2Multiplier := 1.0
var C14Divisor := 1.0
var C10Power := 0.0
func C10Score():
	return sin(Time.get_ticks_msec() / 1000.0)

var RewindMult := largenum.new(1)

var canDilate :
	get: return 
var canGalaxy :
	get:
		if Globals.Challenge in [8, 22]: return false
		return 
var canBigBang:
	get:
		if Globals.Challenge > 15:
			return Globals.ECTargets[Globals.Challenge - 16].less(topTachyonsInEternity)
		var logfinity = 2048 if Globals.Challenge == 15 else 1024
		return (Currencies.Tachyons.AMOUNT.log2() >= logfinity) or (topTachyonsInEternity.log2() >= logfinity)
var topTachyonsInEternity := largenum.new(0)


# ðese functions calculate ðe costs of tickspeed and dimensions.
# boþ of ðem account for scaling past 1.8e308.

func tspcost():
	var start = 3
	var increase = 1
	if Globals.Challenge == 5 or Globals.Challenge == 16:
		increase += 1 - GL.LOG2 / GL.LOG10
	
	var purchase : int = TSpeedCount
	
	var costlog = start + increase * purchase
	
	if costlog >= 308.2547156:
		var scalingamount = log(10 - Globals.OEUHandler.TSpScBought) / GL.LOG10
		var scaling : int = purchase - (308.2547156 - start) / increase
		costlog += scaling * (scaling + 1) * scalingamount / 2
	
	return largenum.ten_to_the(costlog)

func dimcost(which):
	var start = [
		1, 2, 4, 6,
		9,13,18,24
	][which - 1]
	var increase = [
		3, 4, 5, 6,
		8,10,12,15
	][which - 1]
	if Globals.Challenge == 1 or Globals.Challenge == 16:
		increase = [
			4, 6, 8, 10,
			13,15,17,20
		][which - 1]
	var purchase : int = DimPurchase[which - 1] / buylim
	
	var costlog = start + increase * purchase
	
	if costlog >= 308.2547156:
		var scalingamount = log(10 - Globals.OEUHandler.TDmScBought) / GL.LOG10
		var scaling : int = purchase - (308.2547156 - start) / increase
		costlog += scaling * (scaling + 1) * scalingamount / 2
	
	return largenum.ten_to_the(costlog)


# functions for buying tachyon dimensions.
# "tier" goes from 1 to 8
# "times" is for buying multiple dimensions in buy_one()
#  note: you can't go past a cost increase in buy_one()!

func buy_one(tier, times):
	if DimPurchase[tier - 1] % buylim + times > buylim: return false # prevent going above ðe limit
	if Currencies.Tachyons.spend(dimcost(tier).multiply(times)):
		DimPurchase[tier - 1] += times
		latest_purchased = tier
		
		if times == 1 and tier == 1 and DimAmount[0].log10() >= 100:
			if not Globals.Achievemer.is_unlocked(2, 7):
				Globals.Achievemer.set_unlocked(2, 7)
		
		return true
	return false

func buy_until_mult(tier):
	return buy_one(tier, buylim - (DimPurchase[tier - 1] % buylim))

func buy_max(tier):
	while buy_until_mult(tier): pass 

