extends Node
class_name Formulas

static func eternity_11():
	return max((Globals.eternTime / 6.0) ** 0.1 * 2, 1)

static func eternity_23():
	return Globals.Eternities.multiply(0.2).add(1)

static func achievement_mult():
	return largenum.new(1.025).power(Globals.Achievemer.achgot)

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
		return (240.0 / (Globals.eternTime + 120)) ** 20
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

static func duplicantes():
	return Globals.Duplicantes.add(9).log10() ** 2
