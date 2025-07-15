extends Node
class_name Formulas

static func permanence_11():
	return \
		Currencies.Effect.new(max((Globals.eternTime / 6.0) ** 0.1 * 2, 1))

static func permanence_23():
	var base = Currencies.Effect.new(
		Currencies.Permanences.AMOUNT.multiply(0.2).add(1)
	)
	if "2×2" in Globals.Studies.purchased:
		base = Currencies.Effect.new({
			"Base"		: base.value(),
			"After S2×2": base.value().power(4)
		})
	return base

static func achievement_mult():
	var base = Currencies.Effect.new(
		largenum.new(1.05).power(Globals.Achievemer.achgot)
	)
	if Permanence.overcome_upgrade_bought(4):
		base = Currencies.Effect.new({
			"Base"		: base.value(),
			"After OU4": base.value().power(
				overcome_4().value().to_float()
			)
		})
	return base

static func tpgained():
	var tpgain = largenum.two_to_the(3 * (
			Currencies.PermanencePts.AMOUNT.log2() / 1024
		 - 1))
	
	if "5×1" in Globals.Studies.purchased:
		tpgain.mult2self(5)
	
	if tpgain.to_float() < 1e10:
		tpgain = largenum.new(floor(tpgain.to_float()))
	
	return tpgain

static func next_tp():
	if "5×1" in Globals.Studies.purchased:
		return largenum.two_to_the(
			1024 * (tpgained().add(1).divide(5).log2() / 3 + 1)
		)
	return largenum.two_to_the(1024 * (tpgained().add(1).log2() / 3 + 1))

static func overcome_1():
	return Currencies.Effect.new(Currencies.Tachyons.AMOUNT.power(0.01))

static func overcome_4():
	return Currencies.Effect.new(
		Currencies.Permanences.AMOUNT.log2() ** 1.5, Currencies.Effect.Power
	)

static func overcome_7():
	var i : float = -1
	for ch in Globals.challengeTimes:
		if ch > i: i = ch
	if i < 0: return 1
	return Currencies.Effect.new(max(300 / i, 1))

static func overcome_9():
	var base = Currencies.Effect.new(
		Currencies.Permanences.AMOUNT.power(3)
	)
	if "2×2" in Globals.Studies.purchased:
		base = Currencies.Effect.new({
			"Base"		: base.value(),
			"After S2×2": base.value().power(4)
		})
	return base

static func achievement_56():
	if Globals.eternTime < 120:
		return Currencies.Effect.new((240.0 / (Globals.eternTime + 120)) ** 5)
	else: return Currencies.Effect.new(1)

static func ec1_reward():
	var m : float = 1
	for i in 7:
		if Globals.ECCompleted(i + 1):
			m *= 3
	return Currencies.Effect.new(m)

static func ec2_reward():
	var default = TachyonDims.TSpeedBoost.power(
		(TachyonDims.TSpeedCount + PermaDims.FreeTSpeed) * 0.01
	)
	if default.less(largenum.ten_to_the(90)):
		return Currencies.Effect.new(default)
	else:
		return Currencies.Effect.new({"Capped": largenum.ten_to_the(90)})

static func dupli_no1x2():
	return largenum.new(max(Currencies.Duplicantes.AMOUNT.log2() ** 2 * 3, 1))
static func dupli_yes1x2():
	if Currencies.Duplicantes.AMOUNT.exponent < 0:
		return largenum.new(1)
	return Currencies.Duplicantes.AMOUNT.power(0.03)

static func duplicantes():
	var base = Currencies.Effect.new({"Base": dupli_no1x2()})
	if "1×2" in Globals.Studies.purchased:
		base.new_section(
			"After S1×2",
			dupli_no1x2().add(dupli_yes1x2()).add(-1)
		)
	if "Time4" in Globals.Studies.purchased:
		base.new_section(
			"After STime4",
			base.value().power(study_time3().value().to_float())
		)
	return base

static func space_conversion():
	if "6×2" in Globals.Studies.purchased:
		return 0.4
	else: return 1./3.
static func space_power(): # haha typo
	if Globals.SDHandler.BoundlessPower.exponent < 0:
		return largenum.new(1)
	return Globals.SDHandler.BoundlessPower.power(space_conversion())

static func study_tach1():
	return Currencies.Effect.new(TachyonDims.RewindMult.power(0.1))

static func study_time1():
	return Currencies.Effect.new(TachyonDims.RewindMult.power(0.002))
static func study_time2():
	return Currencies.Effect.new(space_power().power(TachyonDims.TDilation * 0.001))
static func study_time3():
	return Currencies.Effect.new(1 + .05 * Duplicantes.dupGalaxies, Currencies.Effect.Power)

static func study_space1():
	return TachyonDims.RewindMult.power(5e-5)
static func study_space2():
	return largenum.new(1.002).power(TachyonDims.TDilation)

static func study_act1():
	var t = 0
	for i in Globals.last10bless.size():
		t += Globals.last10bless[i].time
	return max(1, min(300./t, 50))
