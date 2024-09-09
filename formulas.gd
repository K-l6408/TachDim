extends Node
class_name Formulas

static func eternity_11():
	return max((Globals.eternTime / 6.0) ** 0.1 * 2, 1)

static func eternity_23():
	return Globals.Eternities.multiply(0.2).add(1)

static func achievement_mult():
	return largenum.new(1.025).power(Globals.Achievemer.achgot)

static func epgained():
	var epgain = largenum.new(1)
	if Globals.Challenge == 15 or Globals.progressBL >= Globals.Progression.Overcome:
		epgain = largenum.five_to_the((
			Globals.TDHandler.topTachyonsInEternity.log2() / 1024
		) - 1)
		if Globals.OEUHandler.is_bought(4):
			epgain = largenum.five_to_the((
				Globals.TDHandler.topTachyonsInEternity.log2() / 900
			) - 1)
	
	epgain.mult2self(largenum.two_to_the(Globals.EUHandler.EPMultBought))
	
	if epgain.to_float() < 1e10:
		epgain = largenum.new(floor(epgain.to_float() + 0.1))
	
	return epgain

static func bpgained():
	var bpgain = largenum.ten_to_the((
			Globals.EternityPts.log2() / 1024
		) - 1)
	
	#bpgain.mult2self(largenum.two_to_the(Globals.EUHandler.EPMultBought))
	
	if bpgain.to_float() < 1e10:
		bpgain = largenum.new(floor(bpgain.to_float()))
	
	return bpgain

static func next_bp():
	return largenum.two_to_the(1024 * (bpgained().add(1).log10() + 1))

static func overcome_1():
	return Globals.Tachyons.power(0.01)

static func overcome_7():
	var i : float = -1
	for ch in Globals.challengeTimes:
		if ch > i: i = ch
	if i < 0: return 1
	return max(300 / i, 1)

static func overcome_9():
	return Globals.Eternities.power(2)

static func achievement_56():
	if Globals.eternTime < 120:
		return (240.0 / (Globals.eternTime + 120)) ** 5
	else: return 1

static func ec1_reward():
	var m : float = 1
	for i in 15:
		if Globals.ECCompleted(i + 1):
			m *= 3
	return m

static func ec2_reward():
	return max(Globals.TDHandler.TSpeedBoost.power(
		Globals.TDHandler.TSpeedCount + Globals.EDHandler.FreeTSpeed
	).log10(), 1)

static func dupli_no11():
	return max(Globals.Duplicantes.add(9).log10() ** 2, 1)
static func dupli_yes11():
	return Globals.Duplicantes.power(0.03).add2self(dupli_no11())

static func duplicantes():
	if "1×1" not in Globals.Studies.purchased:
		return dupli_no11()
	else:
		return dupli_yes11()
