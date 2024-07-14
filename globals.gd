extends Node
class_name GL

enum DisplayMode {
	Scientific, Engineering, Logarithm, Letters, Dozenal, Strict_Logarithm, Roman,
	toki_pona, sitelen_pona, Canonical_toki_pona
}
enum Progression {
	None, Dilation, Galaxy, Eternity, Overcome
}
const LOG2  = log(2)
const LOG10 = log(10)
const LOG12 = log(12)

var display  : DisplayMode = DisplayMode.Scientific
var progress : Progression = Progression.None

var Tachyons  := largenum.new(10)
var TachTotal := largenum.new(10)

var TDilation := 0
var TGalaxies := 0

var EternityPts := largenum.new(0)
var Eternities  := largenum.new(0)

var Challenge := 0
var CompletedChallenges := 0

func challengeCompleted(which): return (CompletedChallenges >> (which - 1)) & 1

var TDHandler  : Control
var Automation : Control
var Achievemer : Control
var VisualSett : Control
var EUHandler  : Control

var NotifHandler : Control

var AnimOpt : Array[bool] = [true]

var Animater : AnimationPlayer
func animation(which):
	if which == "bang" and not AnimOpt[0]: return
	Animater.play(which)

var existence := 0

func _process(delta):
	existence += int(delta * 1000)

func int_to_string(i:int) -> String:
	match display:
		DisplayMode.Canonical_toki_pona:
			if i < 1: return "ala"
			if i < 2: return "wan"
			if i < 3: return "tu"
			return "mute"
		DisplayMode.sitelen_pona:
			return largenum.sitelen(i, true)
		DisplayMode.toki_pona:
			return largenum.sitelen(i, true)\
			.replace("󱥳", " wan").replace("󱥮", " tu")\
			.replace("󱤭", " luka").replace("󱤼", " mute")\
			.replace("󱤄", " ale").replace("󱤂", " ala").trim_prefix(" ")
		DisplayMode.Strict_Logarithm:
			return "e" + String.num(log(i) / LOG10, 2).replace("inf", "∞")
		DisplayMode.Dozenal:
			return largenum.dozenal(i, 0)
		DisplayMode.Roman:
			return largenum.roman(i)
		_:
			return str(i)

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
			return "e" + String.num(log(f) / LOG10, precision).pad_decimals(precision)
		DisplayMode.Logarithm:
			if f < 1e5:
				return String.num(f, precision).pad_decimals(precision)
			else:
				return "e" + String.num(log(f) / LOG10, precision).pad_decimals(precision)
		DisplayMode.Dozenal:
			if f > 12**3:
				return largenum.dozenal(fmod(f, 12), precision) + "e" + largenum.dozenal(log(f) / LOG12,0)
			return largenum.dozenal(f, precision)
		DisplayMode.Roman:
			return largenum.roman(f)
		_:
			if f > 1000:
				return "%.2fe" % fmod(f, 10) + String.num(log(f) / LOG10,0)
			return String.num(f, precision).pad_decimals(precision)

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
		DisplayMode.Dozenal:
			match n%12:
				1: return int_to_string(n) + "st"
				2: return int_to_string(n) + "nd"
				3: return int_to_string(n) + "rd"
				_: return int_to_string(n) + "th"
		_:
			if n%100-n%10 == 10: return int_to_string(n) + "th"
			match n%10:
				1: return int_to_string(n) + "st"
				2: return int_to_string(n) + "nd"
				3: return int_to_string(n) + "rd"
				_: return int_to_string(n) + "th"

func notificate(type:String, text:String):
	NotifHandler.notif(type, text)
