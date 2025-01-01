extends Node

const TIMESPEED = 9
const REWIND	= 10
const DILATION	= 11
const GALAXY	= 12
const BIG_BANG	= 13

var NormUnlocked := 0
var NormEnabled  := 0
var NormModes    := 0

func get_bit(i:int, b:int):
	return (i & (1 << (b-1))) > 0
func set_bit(i:int, to:bool, b:int): # doesn't actually change ðe number
	if to:
		if get_bit(i, b):
			return i
		return i + (1 << (b-1))
	else:
		if not get_bit(i, b):
			return i
		return i - (1 << (b-1))

func unlock_buyer(b:int):
	NormUnlocked = set_bit(NormUnlocked, true, b)
func set_enabled(to:bool, b:int):
	NormEnabled = set_bit(NormEnabled, to, b)
func change_mode(to:bool, b:int):
	NormModes = set_bit(NormModes, to, b)

var NormUpgrades := [0, 0, 0, 0, 0, 0, 0, 0, 0]
var RewdUpgrades := 0
var RewdAQups    := 0
var DilUpgrades  := 0
var GalUpgrades  := 0
var BangUpgrades := 0
var NormTimers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

var DilLimit  := 0
var DilIgnore := 0
var GalLimit  := 0
var BigBangMode := 0
### mode explanation ###
#    0: +X EP          #
#    1: ×X max EP      #
#    2:  X seconds     #
########################

func set_big_bang_mode(to:int):
	BigBangMode = to

var DilaTimeOverride := 0.0
var GalaTimeOverride := 0.0

var  RewindObjective := 2.0
var BigBangObjective := largenum.new(1)
var BigBangObjectStr := "1"

const IntervalCap := [3, 4, 4, 4, 5, 5, 5, 5]

func reset():
	if Globals.Boundlessnesses.to_float() < 2:
		NormUnlocked = 0
		NormUpgrades = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	RewdUpgrades = 0
	RewdAQups = 0
	DilUpgrades = 0
	GalUpgrades = 0
	BangUpgrades = 0

func TDInterval(which):
	var i = (0.4 + which * 0.1) * (0.6 ** NormUpgrades[which - 1])
	if i < 0.101: return 0.1
	return i
func TSpeedInterval():
	var i = 0.5 * (0.6 ** NormUpgrades[-1])
	if i < 0.101: return 0.1
	return i
func RewdAccuracy():
	var i = 0.5 * (1.095 ** RewdAQups)
	if i > 1: return 1
	return i
func RewdInterval():
	if Globals.Achievemer.is_unlocked(5, 2):
		RewdUpgrades = 7
		return 0
	var i = 3 * (0.6 ** RewdUpgrades)
	if i < 0.101: return 0.1
	return i
func DilInterval():
	if Globals.OEUHandler.is_bought(2):
		return DilaTimeOverride
	var i = 4 * (0.6 ** DilUpgrades)
	if i < 0.101: return 0.1
	return i
func GalInterval():
	var i = 10 * (0.6 ** GalUpgrades)
	if i < 0.101: return 0.1
	return i
func BangInterval():
	var i = 60 * (0.6 ** BangUpgrades)
	if i < 0.101: return 0.1
	return i

func TDBulk(which):
	if Globals.Achievemer.is_unlocked(5, 3):
		return INF
	elif NormUpgrades[which-1] <= IntervalCap[which-1]:
		return 1
	else:
		return max(2 ** (NormUpgrades[which-1] - IntervalCap[which-1]), 512)

func improve_interval(which : int):
	match which:
		TIMESPEED:
			Currencies.EternityPts.spend(2 ** NormUpgrades[-1])
			NormUpgrades[-1]		+= 1
		REWIND:
			Currencies.EternityPts.spend(2 ** RewdUpgrades)
			RewdUpgrades			+= 1
		DILATION:
			Currencies.EternityPts.spend(2 ** DilUpgrades)
			DilUpgrades				+= 1
		GALAXY:
			Currencies.EternityPts.spend(2 ** GalUpgrades)
			GalUpgrades				+= 1
		BIG_BANG:
			Currencies.EternityPts.spend(2 ** BangUpgrades)
			BangUpgrades			+= 1
		_: # Tachyon Dimensions
			Currencies.EternityPts.spend(2 ** NormUpgrades[which-1])
			NormUpgrades[which-1]	+= 1
func improve_rewd_accuracy():
	Currencies.EternityPts.spend(3 ** RewdAQups)
	RewdAQups += 1

func update_bigbang_ep(epgain:String):
	var tree = epgain.split("e")
	var k = largenum.new(0)
	for i in range(tree.size()-1, -1, -1):
		if ";" in tree[i]: # dozenal!
			var j = 0
			var mag = 12.0 ** len(tree[i].split(";")[0])
			var T = tree[i]\
			.replace("X", "↊").replace("E", "↋")\
			.replace("T", "↊").replace("Ɛ", "↋")\
			.replace("τ", "↊").replace("ε", "↋")\
			.replace("A", "↊").replace("B", "↋")\
			.replace("a", "↊").replace("b", "↋")
			for w in T:
				mag /= 12
				match w:
					"↊": j += 10 * mag
					"↋": j += 11 * mag
					";": mag *= 12
					_  : j += w.to_int() * mag
			k = largenum.dozen_to_the(k.to_float()).multiply(j)
		else:
			var j = tree[i].to_float()
			if tree[i] == "": j = 1
			k = largenum.ten_to_the(k.to_float()).multiply(j)
	BigBangObjective = k
	BigBangObjectStr = epgain

func _process(delta):
	if NormUpgrades.size() < 9:
		NormUpgrades.append(0)
	
	if not Globals.Achievemer.is_unlocked(4, 3):
		var do = true
		for i in 9:
			if NormUpgrades[i] < IntervalCap[i]:
				do = false
				break
		if do:
			Globals.Achievemer.set_unlocked(4, 3)
	
	if not Globals.Achievemer.is_unlocked(5, 2):
		if RewdAQups >= 8 and RewdUpgrades >= 7:
			Globals.Achievemer.set_unlocked(5, 2)
	
	if not Globals.Achievemer.is_unlocked(5, 3):
		var do = true
		for i in 8:
			if TDBulk(i+1) < 512 or NormUpgrades[i] < IntervalCap[i]:
				do = false
				break
		if do:
			Globals.Achievemer.set_unlocked(5, 3)
	
	for i in NormTimers.size():
		if get_bit(NormEnabled, i+1):
			if i+1 <= TIMESPEED and not get_bit(NormUnlocked, i+1):
				continue
			NormTimers[i] -= delta
			if NormTimers[i] <= 0:
				match i + 1:
					BIG_BANG:
						if Globals.challengeCompleted(14):
							if Globals.progressBL < GL.Progression.Overcome\
							or Globals.Challenge != 0:
								TachyonDims.eternity()
								NormTimers[i] += BangInterval()
					GALAXY:
						if Globals.challengeCompleted(12):
							if Globals.OEUHandler.is_bought(2):
								TachyonDims.galaxy_max()
							else:
								TachyonDims.galaxy()
							NormTimers[i] += DilInterval()
					DILATION:
						if Globals.challengeCompleted(11) and \
						Globals.Challenge != 10:
							if Globals.OEUHandler.is_bought(2) and \
								TachyonDims.TDilation >= (
									2 if Globals.Challenge in [6, 16] else 4
								):
								TachyonDims.dilate_max()
							else:
								TachyonDims.dilate()
							NormTimers[i] += DilInterval()
					REWIND:
						if Globals.challengeCompleted(10):
							if TachyonDims.rewindScore() >= RewdAccuracy()\
							and not TachyonDims.rewindBoost().\
							divide(TachyonDims.RewindMult).less(RewindObjective):
								TachyonDims.rewind()
								NormTimers[i] += RewdInterval()
							else:
								NormTimers[i] += delta
					TIMESPEED:
						NormTimers[i] += TSpeedInterval()
						if get_bit(NormModes, TIMESPEED):
							TachyonDims.buy_max_tspeed()
						else:
							TachyonDims.buy_tspeed()
					_:
						NormTimers[i] += TDInterval(i+1)
						if get_bit(NormModes, i+1):
							if TDBulk(i+1) == INF:
								TachyonDims.buy_max(i+1)
							else:
								for j in TDBulk(i+1):
									if not TachyonDims.buy_until_mult(i+1, true):
										pass
						else:
							TachyonDims.buy_one(i+1)
	
	if Globals.progressBL >= GL.Progression.Overcome \
	and get_bit(NormEnabled, BIG_BANG+1):
		if Globals.Boundlessnesses.to_float() < 4:
			if BigBangObjective.less(Formulas.epgained()):
				TachyonDims.eternity()
		else:
			match BigBangMode:
				0:
					if BigBangObjective.less(Formulas.epgained()):
						TachyonDims.eternity()
				1:
					if BigBangObjective.less(Formulas.epgained().divide(Currencies.EternityPts)):
						TachyonDims.eternity()
				2:
					if Globals.eternTime >= BigBangObjective.to_float():
						TachyonDims.eternity()
