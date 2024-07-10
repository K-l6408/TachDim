extends Node
class_name Formulas

static func eternity_11():
	return (Globals.existence / 120) ** 0.1 * 2

static func eternity_23():
	return Globals.Eternities.multiply(0.2).add(1)

static func achievement_mult():
	return largenum.new(1.125).power(Globals.Achievemer.achgot)
