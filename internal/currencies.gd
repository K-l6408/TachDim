extends Node

class Currency:
	var AMOUNT := largenum.new(0)
	var RESET  := func(): return largenum.new(0)
	
	func _init(_r):
		if _r is Callable:
			RESET = _r
		if _r is largenum:
			RESET = func(): return _r
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
	
	func spend(n:largenum):
		if not n is largenum:
			n = largenum.new(n)
		if AMOUNT.exponent - n.exponent > 62:
			return true # basically free
		if n.sign > 0 and n.less(AMOUNT):
			AMOUNT.add2self(n.neg())
			return true
		return false
	
	func reset():
		var _r = RESET.call()
		if _r is largenum: AMOUNT = _r
	
	func _to_string():
		return AMOUNT.to_string()

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
