extends Node
class_name GL

class EternityData:
	var time := 0.0
	var epgain := largenum.new(1)
	var eternities := largenum.new(1)
	func _init(t, ep, et):
		time = t
		epgain = largenum.new(ep)
		eternities = largenum.new(et)
	func to_dict():
		var D := {time = time}
		D.epgain = epgain.to_bytes()
		D.eternities = eternities.to_bytes()
		return D
	static func from_dict(D):
		if D == null: return null
		var e = new(-1,1,1)
		e.time = D.time
		e.epgain.from_bytes(D.epgain)
		e.eternities.from_bytes(D.eternities)
		return e

enum DisplayMode {
	Scientific, Engineering, Logarithm, Letters, Dozenal, Strict_Logarithm, Standard,
	Roman, toki_pona, sitelen_pona, Canonical_toki_pona, Evil, Factorial
}
enum Progression {
	None, Dilation, Galaxy, Eternity, Overcome, Duplicantes, Boundlessness
}
const LOG2  = log(2)
const LOG10 = log(10)
const LOG12 = log(12)

var display    : DisplayMode = DisplayMode.Scientific
var progress   : Progression = Progression.None
var progressBL : Progression = Progression.None

var Tachyons  := largenum.new(10)
var TachTotal := largenum.new(10)

var TDilation := 0
var TGalaxies := 0

var EternityPts := largenum.new(0)
var Eternities  := largenum.new(0)

var TachTotalBL     := largenum.new(10)
var BoundlessPts    := largenum.new(0)
var Boundlessnesses := largenum.new(0)

var Duplicantes := largenum.new(1)

var Challenge := 0
var CompletedChallenges := 0
var CompletedECs := 0

func challengeCompleted(which): return (CompletedChallenges >> (which - 1)) & 1
func ECCompleted(which):		return (CompletedECs >> (which - 1)) & 1

var TDHandler  : Control
var EDHandler  : Control
var SDHandler  : Control
var Automation : Control
var Achievemer : Control
var VisualSett : Control
var EUHandler  : Control
var OEUHandler : Control
var DupHandler : Control
var Studies    : Control

var NotifHandler : Control

var AnimOpt : Array[bool] = [true]

var Animater : AnimationPlayer
func animation(which):
	if which == "bang" and not AnimOpt[0]: return
	Animater.play(which)

var existence = 0
var eternTime = 0
var boundTime = 0

var fastestEtern := EternityData.new(-1, 1, 1)
var EU12Timer : SceneTreeTimer = null

var last10etern : Array[EternityData] = []

var challengeTimes = [
	-1, -1, -1,
	-1, -1, -1,
	-1, -1, -1,
	-1, -1, -1,
	-1, -1, -1
]
var ECTimes = [
	-1, -1, -1,
	-1, -1, -1, -1
]

var ECTargets = [
	largenum.two_to_the(2048), largenum.ten_to_the(1500),
	largenum.ten_to_the(9000), largenum.ten_to_the(11500),
	largenum.ten_to_the(7000), largenum.ten_to_the(13000),
	largenum.ten_to_the(30000)
]
const ECUnlocks = [
	1500,  1900,  10000, 12500,
	22222, 33333, 70000, 80000
]

func _process(delta):
	existence += delta
	eternTime += delta
	if EUHandler is Node:
		if EUHandler.is_bought(12) and (EU12Timer == null or EU12Timer.time_left == 0):
			EternityPts.add2self(fastestEtern.epgain)
			EU12Timer = get_tree().create_timer(fastestEtern.time * 3)
	if OEUHandler is Node:
		var avg = largenum.new(0)
		for i in last10etern:
			avg.add2self(i.epgain.divide(i.time))
		avg.div2self(last10etern.size())
		EternityPts.add2self(avg.mult2self(delta * OEUHandler.PasEPBought / 20))
	EternityPts.fix_mantissa()
	if EternityPts.less(0.01):
		EternityPts = largenum.new(0)

func boundlessnessreset():
	boundTime = 0
	CompletedChallenges = 0
	CompletedECs = 0
	EternityPts = largenum.new(0)
	Eternities  = largenum.new(0)
	progressBL = Progression.None
	last10etern = []
	fastestEtern = EternityData.new(-1, 1, 1)
	Automation.reset()
	EUHandler.Bought = 0
	EUHandler.EPMultBought = 0
	OEUHandler.Bought = 0
	OEUHandler.TSpScBought = 0
	OEUHandler.TDmScBought = 0
	OEUHandler.PasEPBought = 0
	EDHandler.DimsUnlocked = 0
	EDHandler.reset()
	DupHandler.reset()
	TDHandler.reset(2)
	TachTotalBL = largenum.new(Tachyons)

func int_to_string(i:int) -> String:
	match display:
		DisplayMode.Strict_Logarithm:
			return "e" + String.num(log(i) / LOG10, 2).replace("inf", "∞")
		_:
			return float_to_string(i, 0, true)

func float_to_string(f:float, precision:=2, force_dec:=false) -> String:
	match display:
		DisplayMode.Canonical_toki_pona:
			if f < 1: return "ala"
			if f < 2: return "wan"
			if f < 3: return "tu"
			return "mute"
		DisplayMode.sitelen_pona:
			return largenum.sitelen(f)
		DisplayMode.toki_pona:
			return largenum.sitelen(f)\
			.replace("󱥳", " wan").replace("󱥮", " tu")\
			.replace("󱤭", " luka").replace("󱤼", " mute")\
			.replace("󱤄", " ale").replace("󱥵", " wawa")\
			.replace("󱥻", " kipisi").replace("󱤊", " en")\
			.replace("󱤂", " ala").replace("󱦂", " meso").trim_prefix(" ")
		DisplayMode.Strict_Logarithm:
			return "e" + String.num(log(f) / LOG10, precision).pad_decimals(precision).replace("inf", "∞")
		DisplayMode.Logarithm:
			if f >= 1000 and not force_dec:
				return "e" + String.num(log(f) / LOG10, precision).pad_decimals(precision)
		DisplayMode.Dozenal:
			if f > 12**3 and not force_dec:
				return largenum.dozenal(fmod(f, 12), precision) + "e" + largenum.dozenal(log(f) / LOG12,0)
			return largenum.dozenal(f, precision)
		DisplayMode.Roman:
			return largenum.roman(f)
		DisplayMode.Evil:
			var ohno = log(abs(f)) / LOG10
			ohno *= 1 + sin(ohno) / 10
			if f != 0: f = 10 ** ohno * sign(f)
			if f >= 1000 and not force_dec:
				return "%.2fe" % (f / (10.0 ** floor(log(f) / LOG10))) + String.num(log(f) / LOG10,0)
			return String.num(f, precision).pad_decimals(precision)
		DisplayMode.Factorial:
			if f >= 1000 and not force_dec:
				return "%.2f!" % invfact(f)
		DisplayMode.Standard:
			if f >= 1000 and not force_dec:
				var loga = floor(log(f) / 3 / LOG10)
				if f / (1000.0 ** loga) > 999.9:
					loga += 1
				return String.num((f / (1000.0 ** loga)), precision)\
				.pad_decimals(precision) + " " + largenum.standard(int(loga) - 1)
		DisplayMode.Letters:
			if f >= 1000 and not force_dec:
				var l = log(f) / LOG10
				if l == -INF:
					return "0.00"
				f = 10 ** (l - floor(l))
				var s = ""
				var alpha = "abcdefghijklmnopqrstuvwxyz"
				if f > 9.99:
					l += 1
					f /= 10
				var k = ceil(fmod(l, 3) - 0.9999999)
				l = floor(l / 3)
				while l >= 1:
					s = alpha[(fmod(l, 26) as int) - 1] + s
					l /= 27
				return String.num(f * 10**k, precision)\
				.pad_decimals(precision) + s
		_:
			if f >= 1000 and not force_dec:
				var l = log(f) / LOG10
				if f / (10.0 ** floor(l)) > 9.9:
					l += 1
				return String.num(f / (10.0 ** floor(l)), precision)\
				.pad_decimals(precision) + "e" + str(int(l))
	return String.num(f, precision).pad_decimals(precision)

func format_time(f:float) -> String:
	var hour = 3600
	var day = hour * 24
	var year = day * 365.2422
	if f >= year * 10:	return "%s years" % float_to_string(f / year)
	if f >=  day * 10:	return "%s days"  % float_to_string(f / day)
	if f >=  day:		return "%s day%s, %s:%s:%s" % [
		int_to_string(f / day), "s" if f >= day*2 else "",
		pad_zeroes(int_to_string(int(f / hour) % 24)),
		pad_zeroes(int_to_string(int(f / 60) % 60)),
		pad_zeroes(int_to_string(int(f) % 60))]
	if f >= hour:		return "%s:%s:%s" % [
		pad_zeroes(int_to_string(f / hour)),
		pad_zeroes(int_to_string(int(f / 60) % 60)),
		pad_zeroes(int_to_string(int(f) % 60))]
	if f >=   60:		return "%s:%s" % [
		pad_zeroes(int_to_string(int(f / 60) % 60)),
		pad_zeroes(int_to_string(int(f) % 60))]
	if f >=    1:		return "%ss" % float_to_string(f)
	return "%sms" % int_to_string(f * 1000)

func pad_zeroes(s:String, howmany := 2):
	var num = 0
	for ch in s:
		if ch.is_valid_int() or \
		(display == DisplayMode.Dozenal and ch in "↊↋"):
			num += 1
		if ch in ".;":
			break
	if num >= howmany: return s
	for ch in len(s):
		if s[ch].is_valid_int():
			for i in (howmany - num):
				s = s.insert(ch, "0")
			break
	return s

func percent_to_string(f:float, precision:=2) -> String:
	match display:
		DisplayMode.toki_pona:
			return float_to_string(f * 100) + " pi ale"
		DisplayMode.sitelen_pona:
			return float_to_string(f * 100) + "󱦓󱤄󱦔"
		DisplayMode.Strict_Logarithm:
			return "%s/e2" % float_to_string(f * 100, precision + 1)
		DisplayMode.Dozenal:
			return float_to_string(f * 144, precision) + "pß"
		DisplayMode.Roman:
			return float_to_string(f * 100) + "÷C"
		_:
			return float_to_string(f * 100, precision) + "%"

func ordinal(n:int) -> String:
	match display:
		DisplayMode.toki_pona, DisplayMode.Canonical_toki_pona:
			return "nanpa " + int_to_string(n)
		DisplayMode.sitelen_pona:
			return "󱤽" + int_to_string(n)
		DisplayMode.Roman:
			return int_to_string(n) + "°"
		DisplayMode.Strict_Logarithm:
			return int_to_string(n) + "th"
		_:
			if display != DisplayMode.Dozenal and n%100-n%10 == 10:
				return int_to_string(n) + "th"
			match int_to_string(n)[-1]:
				"1": return int_to_string(n) + "st"
				"2": return int_to_string(n) + "nd"
				"3": return int_to_string(n) + "rd"
				_: return int_to_string(n) + "th"

func invfact(a:float) -> float: # approximation of ðe gamma function's inverse
	var L = log(a / sqrt(TAU))
	return L / lambertw(L / exp(1)) - 0.5

func lambertw(a:float) -> float: # approximation of ðe lambert W_0 function
	var lg = log(a)
	var w = lg * (1 - log(lg) / (lg + 1))
	var ew = exp(w)
	w = w - (w * ew - a) / ew / (w + 1)
	ew = exp(w)
	w = w - (w * ew - a) / ew / (w + 1)
	return w

func notificate(type:String, text:String):
	NotifHandler.notif(type, text)
