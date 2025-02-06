extends Node

class Currency:
	var AMOUNT := largenum.new(0)
	var RESET  := func(): return largenum.new(0)
	var spendable = true
	var mults := {}
	
	func _init(_r = null, can_spend := true):
		if _r is Callable:
			RESET = _r
		if _r is largenum:
			RESET = func(): return _r
		spendable = can_spend
	func _save():
		return AMOUNT.to_bytes()
	func _load(_from):
		AMOUNT.from_bytes(_from)
	
	func add(n):
		if not n is largenum:
			n = largenum.new(n)
		if n.sign > 0:
			AMOUNT.add2self(n)
			return true
		return false
	
	func spend(n):
		if not n is largenum:
			n = largenum.new(n)
		if AMOUNT.exponent - n.exponent > 62:
			return true # basically free
		if n.sign > 0 and n.less(AMOUNT):
			if spendable: AMOUNT.add2self(n.neg())
			return true
		return false
	
	func reset():
		var _r = RESET.call()
		if _r is largenum: AMOUNT = _r
	
	func _to_string():
		return AMOUNT.to_string()

class Multiplier:
	var power : largenum
	var dims := 1
	var is_power := false
	func _init(_power : largenum, _dims := 1, _is_power := false):
		power    = _power
		dims     = _dims
		is_power = _is_power

var Tachyons := Currency.new(
	func():
		if   Globals.Achievemer.is_unlocked(6,4):
			return largenum.ten_to_the(25.6989)
		elif Globals.Achievemer.is_unlocked(4,2):
			return largenum.ten_to_the(5.6989)
		elif Globals.Achievemer.is_unlocked(3,6):
			return largenum.ten_to_the(3.6989)
		elif Globals.Achievemer.is_unlocked(2,8):
			return largenum.ten_to_the(2)
		else:
			return largenum.ten_to_the(1)
)

var PermanencePts := Currency.new(
	func():
		return largenum.new(0)
)
var Permanences := Currency.new(null, false)
