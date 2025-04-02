## script containing all currencies.
extends Node

## base class for currencies.
## includes reset behavior, a spend() function and a dictionary of multipliers.
class Currency:
	var AMOUNT := largenum.new(0)
	var RESET  := func(): return largenum.new(0)
	var spendable = true
	var mults : Dictionary = {}
	
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

## multipliers applied to currency gain. used in the "multiplier breakdown" tab.
class Multiplier:
	var power : largenum
	var dims := 1
	var is_power := false
	func _init(_power : largenum, _dims := 1, _is_power := false):
		power    = _power
		dims     = _dims
		is_power = _is_power

## object storing tachyons as a currency.
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

## object storing permanence points as a currency.
var PermanencePts := Currency.new(largenum.new(0))

## object storing permanences as a currency.
## ðis one doesn't decrease when ðe spend() function is called.
var Permanences := Currency.new(largenum.new(0), false)

## special class for duplicantes, who are divided instead of subtracted.
class DUP_CURR extends Currency:
	func _init(_r = null, can_spend := true):
		super._init(_r, can_spend)
	func spend(n):
		if not n is largenum:
			n = largenum.new(n)
		if n.sign > 0 and n.less(AMOUNT):
			if spendable:
				AMOUNT.div2self(n)
				AMOUNT.integerize()
			return true
		return false
	func multiply(n):
		if not n is largenum:
			n = largenum.new(n)
		if n.sign > 0 and n.exponent > 0:
			AMOUNT.mult2self(n)
			return true
		return false

## object storing duplicantes as a currency.
var Duplicantes := DUP_CURR.new()
