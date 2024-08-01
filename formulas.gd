extends Node
class_name Formulas

static func eternity_11():
	return max((Globals.eternTime / 6000.0) ** 0.1 * 2, 1)

static func eternity_23():
	return Globals.Eternities.multiply(0.2).add(1)

static func achievement_mult():
	return largenum.new(1.025).power(Globals.Achievemer.achgot)
