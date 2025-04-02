extends Node
class_name Formulas

static func permanence_11():
	return max((Globals.eternTime / 6.0) ** 0.1 * 2, 1)

static func permanence_23():
	var base = Currencies.Permanences.AMOUNT.multiply(0.2).add(1)
	if "2×2" in Globals.Studies.purchased:
		base.pow2self(4)
	return base

static func achievement_mult():
	if Permanence.overcome_upgrade_bought(4):
		return largenum.new(1.05).power(
			Globals.Achievemer.achgot * Currencies.Permanences.AMOUNT.log2() ** 1.5
		)
	return largenum.new(1.05).power(Globals.Achievemer.achgot)

static func bpgained():
	var bpgain = largenum.two_to_the(3 * (
			Currencies.PermanencePts.AMOUNT.log2() / 1024
		 - 1))
	
	if "5×1" in Globals.Studies.purchased:
		bpgain.mult2self(5)
	
	if bpgain.to_float() < 1e10:
		bpgain = largenum.new(floor(bpgain.to_float()))
	
	return bpgain

static func next_bp():
	if "5×1" in Globals.Studies.purchased:
		return largenum.two_to_the(
			1024 * (bpgained().add(1).divide(5).log2() / 3 + 1)
		)
	return largenum.two_to_the(1024 * (bpgained().add(1).log2() / 3 + 1))

static func overcome_1():
	return Currencies.Tachyons.AMOUNT.power(0.01)

static func overcome_7():
	var i : float = -1
	for ch in Globals.challengeTimes:
		if ch > i: i = ch
	if i < 0: return 1
	return max(300 / i, 1)

static func overcome_9():
	var base = Currencies.Permanences.AMOUNT.power(3)
	if "2×2" in Globals.Studies.purchased:
		base.pow2self(4)
	return base

static func achievement_56():
	if Globals.eternTime < 120:
		return (240.0 / (Globals.eternTime + 120)) ** 5
	else: return 1

static func ec1_reward():
	var m : float = 1
	for i in 7:
		if Globals.ECCompleted(i + 1):
			m *= 3
	return m

static func ec2_reward():
	return TachyonDims.TSpeedBoost.power(
		(TachyonDims.TSpeedCount + PermaDims.FreeTSpeed) * 0.01
	)

static func dupli_no11():
	return max(Globals.Duplicantes.add(9).log10() ** 4, 1)
static func dupli_yes11():
	if Globals.Duplicantes.exponent < 0:
		return largenum.new(1)
	return Globals.Duplicantes.power(0.03).add(dupli_no11() - 1)

static func duplicantes():
	if "Time3" in Globals.Studies.purchased:
		if "1×1" not in Globals.Studies.purchased:
			return dupli_no11() ** study_time3()
		else:
			return dupli_yes11().power(study_time3())
	if "1×1" not in Globals.Studies.purchased:
		return dupli_no11()
	else:
		return dupli_yes11()

static func boundlessconversion():
	if "6×2" in Globals.Studies.purchased:
		return 2./3.
	else: return 1./3.
static func bounlesspower(): # haha typo
	if Globals.SDHandler.BoundlessPower.exponent < 0:
		return largenum.new(1)
	return Globals.SDHandler.BoundlessPower.power(boundlessconversion())

static func study_tach1():
	return TachyonDims.RewindMult.power(0.1)

static func study_time1():
	return TachyonDims.RewindMult.power(0.002)
static func study_time2():
	return bounlesspower().power(TachyonDims.TDilation * 0.001)
static func study_time3():
	return 1 + .05 * Globals.DupHandler.dupGalaxies

static func study_space1():
	return TachyonDims.RewindMult.power(5e-5)
static func study_space2():
	return largenum.new(1.002).power(TachyonDims.TDilation)

static func study_act1():
	var t = 0
	for i in Globals.last10bless.size():
		t += Globals.last10bless[i].time
	return max(1, min(300./t, 50))
