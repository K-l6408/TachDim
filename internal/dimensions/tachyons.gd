extends Node

var DimAmount : Array[largenum] = [
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
]
var DimPurchase : Array[int] = [0,0,0,0,0,0,0,0]
const TSpeedScaleStart := 305
var Multipliers : Array[largenum] = [
	largenum.new(1),largenum.new(1),largenum.new(1),largenum.new(1),
	largenum.new(1),largenum.new(1),largenum.new(1),largenum.new(1)
]

var TDilation := 0
var TGalaxies := 0

var DistantScaling :
	get: return 75

var TSpeedBoost :
	get:
		var GalaxyBoost = 0.975
		var GalaxyMult = 1
		
		if Permanence.upgrade_bought(8): GalaxyMult *= 2
		if Permanence.overcome_upgrade_bought(3): GalaxyMult *= 1.4
		if Globals.ECCompleted(4): GalaxyMult *= 1.15
		
		return largenum.new(1.10 if Globals.Challenge == 12 else 1.125).\
		div2self(largenum.new(GalaxyBoost).power(
			(TGalaxies + Globals.DupHandler.dupGalaxies) * GalaxyMult
		))
var TSpeedCount := 0

var DimsUnlocked :
	get:
		if Globals.Challenge in [6, 16]:
			return min(6, 4 + TDilation)
		return min(8, 4 + TDilation)

var buylim : int :
	get:
		if Globals.Challenge == 5 or Globals.Challenge == 16:	return 15
		else:													return 10
var latest_purchased = 1
var buymult := 2.0
var dilamult = largenum.new(2.0)

var C2Multiplier := 1.0
var C14Divisor := 1.0
var C10Power := 0.0
func C10Score():
	return sin(Time.get_ticks_msec() / 1000.0)

var RewindMult := largenum.new(1)

var canDilate :
	get:
		if (not Globals.Overcame) and canBigBang: return false
		if TDilation >= 5 and Globals.Challenge == 8: return false
		return (DimPurchase[DimsUnlocked - 1] >= dilacost())
var canRewind :
	get:
		if (not Globals.Overcame) and canBigBang: return false
		if rewindBoost().less(RewindMult): return false
		if Globals.Challenge != 13 and TDilation < 5: return false
		if Globals.Challenge != 13 and DimPurchase[7] == 0: return false
		return true
var canGalaxy :
	get:
		if (not Globals.Overcame) and canBigBang: return false
		if Globals.Challenge in [8, 22]: return false
		if Globals.Challenge in [6, 16]:
			return (DimPurchase[5] >= galacost())
		return (DimPurchase[7] >= galacost())
var canBigBang:
	get:
		if Globals.Challenge > 15:
			return Globals.ECTargets[Globals.Challenge - 16].less(topTachyonsInPermanence)
		var logfinity = 2048 if Globals.Challenge == 15 else 1024
		return (topTachyonsInPermanence.log2() >= logfinity)
var topTachyonsInPermanence := largenum.new(0)


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
		var scalingamount = log(10 - Permanence.TSpScBought) / GL.LOG10
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
		var scalingamount = log(10 - Permanence.TDmScBought) / GL.LOG10
		var scaling : int = purchase - (308.2547156 - start) / increase
		costlog += scaling * (scaling + 1) * scalingamount / 2
	
	return largenum.ten_to_the(costlog)

func continuum(which, T = Currencies.Tachyons.AMOUNT.log10()):
	var I = [3, 4, 5, 6, 8, 10, 12, 15][which - 1]
	var S = [1, 2, 4, 6, 9, 13, 18, 24][which - 1] - I + 1
	var X = 308.2547156
	var J = (X-S)/I
	var K = log(10 - Permanence.TDmScBought) / GL.LOG10
	
	if T < X: return (T-S)/I * buylim
	
	var a = K/2
	var b = (K/2 - J*K + I)
	var c = (J*K/2*(J-1) + S - T)
	
	var Δ = b*b - 4*a*c
	var P = (sqrt(Δ) - b) /a /2
	return P * buylim

# functions for buying tachyon dimensions.
# "tier" goes from 1 to 8
# "times" is for buying multiple dimensions in buy_one()
#  note: you can't go past a cost increase in buy_one()!

func buy_one(tier, times = 1):
	if tier > DimsUnlocked: return false
	
	if tier != 1:
		if DimPurchase[tier - 2] == 0: return false
	
	if DimPurchase[tier - 1] % buylim + times > buylim:
		return false # prevent going above ðe limit
	
	if not Globals.Overcame and \
	dimcost(tier).log2() > (1024 if Globals.Challenge != 15 else 2048):
		return false
	
	if Currencies.Tachyons.spend(dimcost(tier).multiply(times)):
		DimPurchase[tier - 1] += times
		latest_purchased = tier
		
		if  DimAmount[tier - 1].exponent < 64:
			DimAmount[tier - 1].add2self(times)
		
		if times == 1 and tier == 1 and DimAmount[0].log10() >= 100:
			if not Globals.Achievemer.is_unlocked(2, 7):
				Globals.Achievemer.set_unlocked(2, 7)
		
		if Globals.Challenge in [2, 16]:  C2Multiplier = 0.0
		if Globals.Challenge in [14, 16]:  C14Divisor = 1.0
		if Globals.Challenge == 7:
			for i in tier:
				DimAmount[i] = largenum.new(DimPurchase[i])
		
		return true
	return false

func buy_until_mult(tier, force := false):
	if not buy_one(tier, buylim - (DimPurchase[tier - 1] % buylim)):
		if force: return false
		while buy_one(tier): pass
	return true

func buy_max(tier):
	if tier > DimsUnlocked: return false
	
	if tier != 1:
		if DimPurchase[tier - 2] == 0: return false
	
	if largenum.two_to_the(62).less(Currencies.Tachyons.AMOUNT.divide(dimcost(tier))):
		DimPurchase[tier - 1]
	
	while buy_until_mult(tier, true): pass 

# functions for buying timespeed. noþing of note here.

func buy_tspeed():
	if Globals.Challenge == 20: return false
	if Currencies.Tachyons.spend(tspcost()):
		TSpeedCount += 1
		if Globals.Challenge == 2 or Globals.Challenge == 16: C2Multiplier = 0.0
		if Globals.Challenge == 14:  C14Divisor = 1.0
		return true
	return false

func buy_max_tspeed():
	while buy_tspeed(): pass

func rewind():
	if not (
		Globals.Achievemer.is_unlocked(3, 5) or
		rewindBoost().divide(RewindMult).less(600)
	):
		Globals.Achievemer.set_unlocked(3, 5) # rewind boost >= ×600, achievement 3×5
	if TachyonDims.rewindScore() >= 0.9:
		if not Globals.Achievemer.is_unlocked(2, 4):
			Globals.Achievemer.set_unlocked(2, 4)
	if RewindMult.less(rewindBoost()):
		RewindMult = rewindBoost()
	if Globals.Challenge == 8:
		var RM = RewindMult
		var TS = TSpeedCount
		reset(0)
		RewindMult = RM
		TSpeedCount = TS
	else:
		for i in 7:
			DimAmount[i].pow2self(1 - TachyonDims.rewindScore())
			if DimAmount[i].less(DimPurchase[i]):
				DimAmount[i] = largenum.new(DimPurchase[i])

func rewindBoost() -> largenum:
	var RBoost : largenum
	if Globals.Challenge == 8:
		RBoost = DimAmount[0].power(0.2)
	elif Permanence.overcome_upgrade_bought(6):
		RBoost = DimAmount[0].power(0.02)
	else:
		RBoost = largenum.new(DimAmount[0].log10() ** 1.5 / 10)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(2)
	
	if Globals.Achievemer.is_unlocked(5, 4): RBoost.pow2self(1.2)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.div2self(RewindMult)
	RBoost.pow2self(TachyonDims.rewindScore())
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(RewindMult)
	
	return RBoost

func rewindScore():
	var rewspd = 0.5
	if Globals.Achievemer.is_unlocked(5, 2):
		rewspd *= 7
	
	var score = sin(Globals.existence * rewspd)
	# sine changed sign (score reached maximum)
	if sin(Globals.existence * rewspd) * \
	sin((Globals.existence - get_process_delta_time()) * rewspd) < 0 or \
	(Globals.existence * rewspd) - \
	((Globals.existence - get_process_delta_time()) * rewspd) >= PI:
		return 1
	return 1 - abs(score)

## resets various content based on "level".
## 0: dilation reset
## 1:  galaxy  reset
## 2: big bang reset
func reset(level := 0, challengeReset := true):
	if level >= 2 and challengeReset: Globals.Challenge = 0
	if Globals.Challenge == 2  or Globals.Challenge == 16: C2Multiplier = 1.0
	if Globals.Challenge == 14 or Globals.Challenge == 16:  C14Divisor = 1.0
	Currencies.Tachyons.reset()
	DimPurchase = [0,0,0,0,0,0,0,0]
	for i in DimAmount:
		i.exponent = -INF # set to zero
		i.fix_mantissa()
	TSpeedCount = 0
	RewindMult = largenum.new(1)
	if level >= 1:
		if   Globals.Challenge == 11 or Globals.Challenge == 16:
			TDilation = -3
		elif Globals.Challenge != 0:
			TDilation = 0
		elif Permanence.upgrade_bought(17):
			TDilation = 5
		elif Permanence.upgrade_bought(16):
			TDilation = 4
		elif Permanence.upgrade_bought(15):
			TDilation = 3
		elif Permanence.upgrade_bought(14):
			TDilation = 2
		elif Permanence.upgrade_bought(13):
			TDilation = 1
		else:
			TDilation = 0
		if Globals.Challenge == 10: C10Power = 0
	if level >= 2:
		if Globals.Challenge != 0:          TGalaxies = 0
		elif Permanence.upgrade_bought(17): TGalaxies = 1
		else:                               TGalaxies = 0
		Globals.eternTime = 0
		topTachyonsInPermanence = largenum.new(0)
		pass

## cost of time dilation. takes into account challenge effects.
func dilacost():
	var Cost := 20
	
	if (Globals.Challenge == 6 or Globals.Challenge == 16) and DimsUnlocked == 6:
		Cost = 30 + (TDilation - 3) * 10
	elif DimsUnlocked == 8:
		Cost = 5 + (TDilation - 3) * 15
	
	if (Globals.Challenge == 5 or Globals.Challenge == 16):
		Cost = Cost * 3 / 2
	if Globals.Challenge == 19:
		Cost += TGalaxies * 15
	if Permanence.upgrade_bought(4):
		Cost -= 5
	if Globals.ECCompleted(4):
		Cost -= 5
	
	return Cost

## cost of tachyon galaxies. takes into account challenge effects and scaling.
func galacost():
	var Cost = 80 + 60 * TGalaxies
	
	if (Globals.Challenge == 6 or Globals.Challenge == 16):
		Cost = 60 + 40 * TGalaxies
	
	if "3×1" in Globals.Studies.purchased:
		Cost -= 5 * TGalaxies
	
	if (Globals.Challenge == 5 or Globals.Challenge == 16):
		Cost = Cost * 3 / 2
	if Globals.Challenge == 19:
		Cost += TDilation * 5
	if Permanence.upgrade_bought(4):
		Cost -= 10
	if TGalaxies > DistantScaling:
		var the = (TGalaxies - DistantScaling)
		Cost += the * (the + 1)
	if TGalaxies > 600:
		var the = (TGalaxies - 600)
		Cost *= 1.002 ** the
	
	return Cost

## prevents softlocks by doing a time dilation reset. doing so costs 1 time dilation.
func antisoftlock():
	reset(0)
	if TDilation > -3:
		TDilation -= 1

func dilate(dim8 = null):
	if dim8 == null:
		if not canDilate:
			return false
	else:
		if dim8 < dilacost(): return false
	reset(0)
	TDilation += 1
	if Globals.Challenge == 10:
		C10Power += 1 - abs(C10Score())
	if  Globals.progress   < Globals.Progression.Dilation:
		Globals.progress   = Globals.Progression.Dilation
	if  Globals.progressBL < Globals.Progression.Dilation:
		Globals.progressBL = Globals.Progression.Dilation
	return true

func dilate_max():
	# buys singles if not all dimensions are unlocked
	if DimsUnlocked != 8 and not (DimsUnlocked == 6 and Globals.Challenge in [6, 16]):
		return dilate()
	var dim8 = DimPurchase[-1]
	while dim8 >= dilacost():
		if not dilate(dim8): return

func galaxy(dim8 = null):
	if dim8 == null:
		if not canGalaxy: return false
	else:
		if dim8 < galacost(): return false
	if Globals.Challenge in [8, 22]: return false
	TGalaxies += 1
	reset(1)
	if  Globals.progress   < Globals.Progression.Galaxy:
		Globals.progress   = Globals.Progression.Galaxy
	if  Globals.progressBL < Globals.Progression.Galaxy:
		Globals.progressBL = Globals.Progression.Galaxy

func galaxy_max():
	var dim8 = DimPurchase[-1]
	while dim8 >= galacost():
		if not galaxy(dim8): return


func permanence(resetchallenge := true):
	if not canBigBang: return
	
	if resetchallenge:
		if Globals.Challenge != 0 and Globals.Challenge <= 15:
			Globals.CompletedChallenges |= 1 << (Globals.Challenge - 1)
			if  Globals.challengeTimes[Globals.Challenge - 1] > Globals.eternTime \
			or  Globals.challengeTimes[Globals.Challenge - 1] < 0:
				Globals.challengeTimes[Globals.Challenge - 1] = Globals.eternTime
		if Globals.Challenge > 15:
			Globals.CompletedECs |= 1 << (Globals.Challenge - 16)
			if Globals.ECTimes.size() < Globals.Challenge - 15:
				Globals.ECTimes.append(-1)
			if  Globals.ECTimes[Globals.Challenge - 16] > Globals.eternTime \
			or  Globals.ECTimes[Globals.Challenge - 16] < 0:
				Globals.ECTimes[Globals.Challenge - 16] = Globals.eternTime
	
	var ppgain = Permanence.process_pp_gain()
	var etgain = 1
	
	ppgain.integerize()
	
	if "2×1" in Globals.Studies.purchased:
		etgain = max(TDilation, 1)
	
	Currencies.PermanencePts.add(ppgain)
	Currencies.Permanences  .add(etgain)
	
	if  Globals.progress   < Globals.Progression.Permanence:
		Globals.progress   = Globals.Progression.Permanence
	if  Globals.progressBL < Globals.Progression.Permanence:
		Globals.progressBL = Globals.Progression.Permanence
	
	if Globals.fastestEtern.time > Globals.eternTime \
	or Globals.fastestEtern.time < 0:
		Globals.fastestEtern.time		= Globals.eternTime
		Globals.fastestEtern.currency	= ppgain
		Globals.fastestEtern.amount		= largenum.new(etgain)
	
	if not Globals.Achievemer.is_unlocked(2, 8):
		Globals.Achievemer.set_unlocked(2, 8)
	if DimPurchase[7] == 0:
		if not Globals.Achievemer.is_unlocked(3, 4):
			Globals.Achievemer.set_unlocked(3, 4)
		if not Globals.Achievemer.is_unlocked(4, 4) and DimPurchase[6] == 0:
			Globals.Achievemer.set_unlocked(4, 4)
	if not Globals.Achievemer.is_unlocked(3, 6) and Globals.eternTime <= 600:
		Globals.Achievemer.set_unlocked(3, 6)
	if not Globals.Achievemer.is_unlocked(4, 2) and Globals.eternTime <= 60:
		Globals.Achievemer.set_unlocked(4, 2)
	if not Globals.Achievemer.is_unlocked(6, 4) and Globals.eternTime <= 0.5:
		Globals.Achievemer.set_unlocked(6, 4)
	if not Globals.Achievemer.is_unlocked(3, 7) and TGalaxies == 1:
		Globals.Achievemer.set_unlocked(3, 7)
	if not Globals.Achievemer.is_unlocked(6, 2) and TGalaxies == 0 and \
	TDilation <= 0:
		Globals.Achievemer.set_unlocked(6, 2)
	if not Globals.Achievemer.is_unlocked(6, 6) and TGalaxies == 0 and \
	TDilation <= -3:
		Globals.Achievemer.set_unlocked(6, 6)
	if not Globals.Achievemer.is_unlocked(7, 5) and ppgain.log10() >= 200:
		Globals.Achievemer.set_unlocked(7, 5)
	
	Globals.last10etern.insert(0, Globals.PrestigeData.new(
		Globals.eternTime, ppgain, etgain
	))
	if Globals.last10etern.size() > 10:
		Globals.last10etern.resize(10)
	
	await get_tree().process_frame
	reset(2, resetchallenge)
	Globals.animation(GL.Animations.BigBang)

func _process(delta):
	var logfinity = 2048 if Globals.Challenge == 15 else 1024
	
	if topTachyonsInPermanence.less(Currencies.Tachyons.AMOUNT):
		topTachyonsInPermanence = largenum.new(Currencies.Tachyons.AMOUNT)
		if not Globals.Overcame and canBigBang:
			topTachyonsInPermanence = \
			largenum.two_to_the(logfinity)
	
	# before overcome or in a regular challenge
	if Globals.progressBL < GL.Progression.Overcome or \
	(Globals.Challenge != 0 and Globals.Challenge <= 15):
		if Currencies.Tachyons.AMOUNT.log2() >= logfinity:
			Currencies.Tachyons.AMOUNT.exponent = logfinity
			Currencies.Tachyons.AMOUNT.mantissa = (1 << 62)
			return
	
	buymult = 2
	if Globals.Challenge == 4: buymult = 1.0 + 0.2 * TDilation
	elif Permanence.upgrade_bought(5): buymult = 2.2222222
	
	dilamult = 2.0
	if Permanence.upgrade_bought(10): dilamult = 2.5
	if Permanence.overcome_upgrade_bought(5): dilamult = 3.0
	if Globals.ECCompleted(7): dilamult = 5.0
	if Globals.Challenge == 10:
		dilamult = 2.2 ** (1 - abs(C10Score()))
	if Globals.Challenge == 8: dilamult = 1
	if Globals.Challenge == 22: dilamult = 10
	if "Tach2" in Globals.Studies.purchased:
		dilamult *= 2
	dilamult = largenum.new(dilamult)
	if Globals.progress >= Globals.Progression.Boundlessness:
		dilamult.mult2self(Formulas.bounlesspower())
	
	if Globals.Challenge == 2  or Globals.Challenge == 16:
		C2Multiplier += delta / 60
		C2Multiplier = min(C2Multiplier, 1)
	if Globals.Challenge == 14 or Globals.Challenge == 16:
		C14Divisor *= 1e9 ** delta
	
	Currencies.Tachyons.mults = {
		"Purchases": [],
		"Timespeed": null,
		"Time Dilation": [],
		"Dimensional Rewind": null,
		"Challenge 2" : null,
		"Challenge 3" : null,
		"Challenge 3 (TD3)" : null,
		"Challenge 9" : null,
		"Challenge 14": null,
		"Achievements": {},
		"Permanence Upgrades": {},
		"Overcome Time Upgrades": {}
	}
	if Globals.Challenge == 18:
		Currencies.Tachyons.mults["Permanence Challenge 3"] = {}
	Currencies.Tachyons.mults["Space Studies"] = {}
	
	for i in range(DimsUnlocked, 0, -1):
		var multiplier = largenum.new(1)
		
		var purchaseMult = largenum.new(buymult).power(floor(DimPurchase[i-1] / buylim))
		multiplier.mult2self(purchaseMult)
		Currencies.Tachyons.mults["Purchases"].\
		push_front(Currencies.Multiplier.new(purchaseMult))
		
		var dilationMult : largenum
		if Globals.Challenge == 10:
			dilationMult = \
				largenum.new(2.2).power(max(      C10Power    - i + 1, 0))
		else:
			dilationMult = \
				dilamult.power(max(TDilation - i + 1, 0))
		multiplier.mult2self(dilationMult)
		Currencies.Tachyons.mults["Time Dilation"].\
		push_front(Currencies.Multiplier.new(dilationMult))
		
		if Globals.Challenge != 13: # mults from Permanence Upgrades are disabled by C13
			if Permanence.upgrade_bought(1):
				multiplier.mult2self(Formulas.permanence_11())
				if not Currencies.Tachyons.mults["Permanence Upgrades"].has("PU 1"):
					Currencies.Tachyons.mults["Permanence Upgrades"]["PU 1"] = \
					Currencies.Multiplier.new(largenum.new(Formulas.permanence_11()), 8)
			
			var k = 0
			if Permanence.upgrade_bought(2):
				if i == 1 or i == 8: multiplier.mult2self(Formulas.permanence_23())
				k += 2
			if Permanence.upgrade_bought(3):
				if i == 2 or i == 7: multiplier.mult2self(Formulas.permanence_23())
				k += 2
			if Permanence.upgrade_bought(7):
				if i == 3 or i == 6: multiplier.mult2self(Formulas.permanence_23())
				k += 2
			if Permanence.upgrade_bought(6):
				if i == 4 or i == 5: multiplier.mult2self(Formulas.permanence_23())
				k += 2
			if k > 0 and \
			not Currencies.Tachyons.mults["Permanence Upgrades"].has("PUs 2, 3, 6, 7"):
				Currencies.Tachyons.mults["Permanence Upgrades"]["PUs 2, 3, 6, 7"] = \
				Currencies.Multiplier.new(Formulas.permanence_23(), k)
			
			if Permanence.upgrade_bought(9):
				multiplier.mult2self(Formulas.achievement_mult())
				if not Currencies.Tachyons.mults["Permanence Upgrades"].has("PU 9"):
					Currencies.Tachyons.mults["Permanence Upgrades"]["PU 9"] = \
					Currencies.Multiplier.new(Formulas.achievement_mult(), 8)
			
			if Permanence.upgrade_bought(11):
				multiplier.mult2self(Currencies.PermanencePts.AMOUNT.add(1))
				if not Currencies.Tachyons.mults["Permanence Upgrades"].has("PU 11"):
					Currencies.Tachyons.mults["Permanence Upgrades"]["PU 11"] = \
					Currencies.Multiplier.new(
						Currencies.PermanencePts.AMOUNT.add(1), 8
					)
		
		if i == 8 or Globals.Challenge == 13:
			multiplier.mult2self(RewindMult)
			if Currencies.Tachyons.mults["Dimensional Rewind"] == null:
				Currencies.Tachyons.mults["Dimensional Rewind"] = \
				Currencies.Multiplier.new(
					RewindMult, 8 if Globals.Challenge == 13 else 1
				)
		elif "Tach1" in Globals.Studies.purchased:
			multiplier.mult2self(Formulas.study_tach1())
			if not Currencies.Tachyons.mults["Space Studies"].has("Tach1"):
				Currencies.Tachyons.mults["Space Studies"]["Tach1"] = \
				Currencies.Multiplier.new(Formulas.study_tach1(), 7)
		
		if "Tach3" in Globals.Studies.purchased and \
		Globals.Duplicantes.exponent > 0:
			multiplier.mult2self(Globals.Duplicantes)
			if not Currencies.Tachyons.mults["Space Studies"].has("Tach3"):
				Currencies.Tachyons.mults["Space Studies"]["Tach3"] = \
				Currencies.Multiplier.new(Globals.Duplicantes, 8)
		
		if Globals.Challenge in [2, 16]:
			multiplier.mult2self(C2Multiplier)
			Currencies.Tachyons.mults["Challenge 2"] = \
			Currencies.Multiplier.new(largenum.new(C2Multiplier), 8)
		if Globals.Challenge == 3:
			if i == 3:
				multiplier.mult2self(3)
				if DimAmount[i-1].exponent != -INF:
					Currencies.Tachyons.mults["Challenge 3 (TD3)"] = \
					Currencies.Multiplier.new(largenum.new(3), 1)
			if i <= 2:
				multiplier.mult2self(0.03)
				Currencies.Tachyons.mults["Challenge 3"] = \
				Currencies.Multiplier.new(largenum.new(0.03), 2)
		if Globals.Challenge == 9 and i != 8:
			multiplier.div2self(Currencies.Tachyons.AMOUNT.power(0.05))
			Currencies.Tachyons.mults["Challenge 9"] = \
			Currencies.Multiplier.new(Currencies.Tachyons.AMOUNT.power(-0.05), 7)
		if Globals.Challenge in [14, 16]:
			multiplier.div2self(C14Divisor)
			Currencies.Tachyons.mults["Challenge 14"] = \
			Currencies.Multiplier.new(largenum.new(C14Divisor).power(-1), 8)
		
		if Globals.Challenge != 13:
			if Globals.Achievemer.is_unlocked(2, 5):
				multiplier.mult2self(1.1)
				if not Currencies.Tachyons.mults["Achievements"].has("2×5"):
					Currencies.Tachyons.mults["Achievements"]["2×5"] = \
					Currencies.Multiplier.new(largenum.new(1.1), 8)
			if Globals.Achievemer.is_unlocked(2, 7) and i == 1:
				multiplier.mult2self(1.5)
				Currencies.Tachyons.mults["Achievements"]["2×7"] = \
				Currencies.Multiplier.new(largenum.new(1.5))
			if Globals.Achievemer.is_unlocked(3, 4) and i != 8:
				multiplier.mult2self(1.5)
				if not Currencies.Tachyons.mults["Achievements"].has("3×4"):
					Currencies.Tachyons.mults["Achievements"]["3×4"] = \
					Currencies.Multiplier.new(largenum.new(1.5), 7)
			if Globals.Achievemer.is_unlocked(4, 8):
				multiplier.mult2self(1.2)
				if not Currencies.Tachyons.mults["Achievements"].has("4×8"):
					Currencies.Tachyons.mults["Achievements"]["4×8"] = \
					Currencies.Multiplier.new(largenum.new(1.2), 8)
			
			if Permanence.overcome_upgrade_bought(1):
				multiplier.mult2self(Formulas.overcome_1())
				if not Currencies.Tachyons.\
				mults["Overcome Time Upgrades"].has("OU 1"):
					Currencies.Tachyons.mults["Overcome Time Upgrades"]["OU 1"] = \
					Currencies.Multiplier.new(Formulas.overcome_1(), 8)
			if Globals.Achievemer.is_unlocked(5, 6):
				multiplier.mult2self(Formulas.achievement_56())
				if not Currencies.Tachyons.mults["Achievements"].has("5×6"):
					Currencies.Tachyons.mults["Achievements"]["5×6"] = \
					Currencies.Multiplier.new(largenum.new(Formulas.achievement_56()), 8)
			
			if Globals.Achievemer.is_unlocked(6, 2) and i <= 4:
				multiplier.mult2self(3)
				if not Currencies.Tachyons.mults["Achievements"].has("6×2"):
					Currencies.Tachyons.mults["Achievements"]["6×2"] = \
					Currencies.Multiplier.new(largenum.new(3), 8)
		
		if not Globals.Achievemer.is_unlocked(3, 1) and multiplier.log10() >= 40:
			Globals.Achievemer.set_unlocked(3, 1)
		
		# POWER EFFECTS GO HERE
		
		if Globals.Challenge == 18 and i != latest_purchased:
			Currencies.Tachyons.mults["Permanence Challenge 3"][i] = \
			Currencies.Multiplier.new(multiplier.power(-0.8), 1, true)
			multiplier.pow2self(0.2)
		
		if "6×1" in Globals.Studies.purchased:
			if not Currencies.Tachyons.mults["Space Studies"].has("6×1"):
				Currencies.Tachyons.mults["Space Studies"]["6×1"] = \
				Currencies.Multiplier.new(multiplier.power(0.02), 8, true)
			multiplier.pow2self(1.02)
		
		#if i != 8:
			#if DimAmount[i].exponent == -INF:	dims[i].get_node("A&G/Growth").hide()
			#else:								dims[i].get_node("A&G/Growth").show()
			#if DimAmount[i-1].exponent == -INF:
				#dims[i+1].modulate.a = 0.5
			#else:
				#dims[i+1].modulate.a = 1.0
		
		Multipliers[i-1] = largenum.new(multiplier)
		
		multiplier.mult2self(TSpeedBoost.power(TSpeedCount + Globals.EDHandler.FreeTSpeed))
		
		var production = DimAmount[i-1].multiply(multiplier)
		if i == 1:
			Currencies.Tachyons.add     (production.multiply(delta))
			Globals.TachTotalBL.add2self(production.multiply(delta))
			Globals.TachTotal  .add2self(production.multiply(delta))
		else:
			DimAmount[i-2].add2self(production.multiply(delta))
		
	Currencies.Tachyons.mults["Timespeed"] = Currencies.Multiplier.new(
		TSpeedBoost.power(TSpeedCount + Globals.EDHandler.FreeTSpeed), DimsUnlocked
	)
