extends Control

const MIN_INTERVAL = 0.1

var Unlocked :
	get:
		var UL = 0
		for i in 9:
			if i == 8:
				if not $Auto/Buyers/TimeSpeedLocked.visible:
					UL += 2 ** i
			elif not get_node("Auto/Buyers/TD%dLocked" % (i+1)).visible:
				UL += 2 ** i
		return UL
	set(value):
		var UL = value
		Unlocked = value
		for i in 9:
			if UL & 1:
				unlock((i + 1) % 9)
			elif i == 8:
				$Auto/Buyers/TimeSpeed/Timer.stop()
				$Auto/Buyers/TimeSpeed.hide()
				$Auto/Buyers/TimeSpeedLocked.show()
			else:
				get_node("Auto/Buyers/TD%d/Timer" % (i + 1)).stop()
				get_node("Auto/Buyers/TD%d" % (i + 1)).hide()
				get_node("Auto/Buyers/TD%dLocked" % (i + 1)).show()
			UL >>= 1
var TDModes :
	get:
		return (
			int($Auto/Buyers/TD1/Mode.button_pressed) * 1 +
			int($Auto/Buyers/TD2/Mode.button_pressed) * 2 +
			int($Auto/Buyers/TD3/Mode.button_pressed) * 4 +
			int($Auto/Buyers/TD4/Mode.button_pressed) * 8 +
			int($Auto/Buyers/TD5/Mode.button_pressed) * 16 +
			int($Auto/Buyers/TD6/Mode.button_pressed) * 32 +
			int($Auto/Buyers/TD7/Mode.button_pressed) * 64 +
			int($Auto/Buyers/TD8/Mode.button_pressed) * 128
		)
	set(value):
		$Auto/Buyers/TD1/Mode.button_pressed = value & 1 << 0 > 0
		$Auto/Buyers/TD2/Mode.button_pressed = value & 1 << 1 > 0
		$Auto/Buyers/TD3/Mode.button_pressed = value & 1 << 2 > 0
		$Auto/Buyers/TD4/Mode.button_pressed = value & 1 << 3 > 0
		$Auto/Buyers/TD5/Mode.button_pressed = value & 1 << 4 > 0
		$Auto/Buyers/TD6/Mode.button_pressed = value & 1 << 5 > 0
		$Auto/Buyers/TD7/Mode.button_pressed = value & 1 << 6 > 0
		$Auto/Buyers/TD8/Mode.button_pressed = value & 1 << 7 > 0
var TDEnabl :
	get:
		return (
			int($Auto/Buyers/TD1/Enabled.button_pressed) * 1 +
			int($Auto/Buyers/TD2/Enabled.button_pressed) * 2 +
			int($Auto/Buyers/TD3/Enabled.button_pressed) * 4 +
			int($Auto/Buyers/TD4/Enabled.button_pressed) * 8 +
			int($Auto/Buyers/TD5/Enabled.button_pressed) * 16 +
			int($Auto/Buyers/TD6/Enabled.button_pressed) * 32 +
			int($Auto/Buyers/TD7/Enabled.button_pressed) * 64 +
			int($Auto/Buyers/TD8/Enabled.button_pressed) * 128 +
			int($Auto/Buyers/TimeSpeed/Enabled.button_pressed) * 256
		)
	set(value):
		$Auto/Buyers/TD1/Enabled.button_pressed = value & 1 << 0 > 0
		$Auto/Buyers/TD2/Enabled.button_pressed = value & 1 << 1 > 0
		$Auto/Buyers/TD3/Enabled.button_pressed = value & 1 << 2 > 0
		$Auto/Buyers/TD4/Enabled.button_pressed = value & 1 << 3 > 0
		$Auto/Buyers/TD5/Enabled.button_pressed = value & 1 << 4 > 0
		$Auto/Buyers/TD6/Enabled.button_pressed = value & 1 << 5 > 0
		$Auto/Buyers/TD7/Enabled.button_pressed = value & 1 << 6 > 0
		$Auto/Buyers/TD8/Enabled.button_pressed = value & 1 << 7 > 0
		$Auto/Buyers/TimeSpeed/Enabled.button_pressed = value & 1 << 8 > 0

var DilLimit:
	get:
		return $Auto/Buyers/Dilation/Limit.value * \
		(1 if $Auto/Buyers/Dilation/Limit/Enabled.button_pressed else -1)
	set(value):
		value = wrapi(value, -128, 127)
		$Auto/Buyers/Dilation/Limit.value = abs(value)
		$Auto/Buyers/Dilation/Limit/Enabled.button_pressed = (sign(value) > 0)
var DilIgnore:
	get:
		return $Auto/Buyers/Dilation/Ignore.value * \
		(1 if $Auto/Buyers/Dilation/Ignore/Enabled.button_pressed else -1)
	set(value):
		value = wrapi(value, -128, 127)
		$Auto/Buyers/Dilation/Ignore.value = abs(value)
		$Auto/Buyers/Dilation/Ignore/Enabled.button_pressed = (sign(value) > 0)
var GalLimit:
	get:
		return $Auto/Buyers/Galaxy/Limit.value * \
		(1 if $Auto/Buyers/Galaxy/Limit/Enabled.button_pressed else -1)
	set(value):
		value = wrapi(value, -128, 127)
		$Auto/Buyers/Galaxy/Limit.value = abs(value)
		$Auto/Buyers/Galaxy/Limit/Enabled.button_pressed = (sign(value) > 0)

var BigBangAtEP := largenum.new(1)

var EPMultEnabled:
	get:
		return $Auto/Buyers/EPMult/Enabled.button_pressed \
		and    $Auto/Buyers/EPMult.visible

var DupChEnabled:
	get:
		return $Auto/Buyers/DupCh/Enabled.button_pressed \
		and    $Auto/Buyers/DupCh.visible

var DupIntEnabled:
	get:
		return $Auto/Buyers/DupInt/Enabled.button_pressed \
		and    $Auto/Buyers/DupInt.visible

var DupGalEnabled:
	get:
		return $Auto/Buyers/DupGal/Enabled.button_pressed \
		and    $Auto/Buyers/DupGal.visible

var EDEnabl :
	get:
		return (
			int($"Auto/Buyers/EDs/Buyers/1/Enabled".button_pressed) * 1 +
			int($"Auto/Buyers/EDs/Buyers/2/Enabled".button_pressed) * 2 +
			int($"Auto/Buyers/EDs/Buyers/3/Enabled".button_pressed) * 4 +
			int($"Auto/Buyers/EDs/Buyers/4/Enabled".button_pressed) * 8 +
			int($"Auto/Buyers/EDs/Buyers/5/Enabled".button_pressed) * 16 +
			int($"Auto/Buyers/EDs/Buyers/6/Enabled".button_pressed) * 32 +
			int($"Auto/Buyers/EDs/Buyers/7/Enabled".button_pressed) * 64 +
			int($"Auto/Buyers/EDs/Buyers/8/Enabled".button_pressed) * 128
		) * (1 if $Auto/Buyers/EDs/Enabled.button_pressed else -1)
	set(value):
		$Auto/Buyers/EDs/Enabled.button_pressed = (value >= 0)
		value = abs(value)
		$"Auto/Buyers/EDs/Buyers/1/Enabled".button_pressed = value & 1 << 0 > 0
		$"Auto/Buyers/EDs/Buyers/2/Enabled".button_pressed = value & 1 << 1 > 0
		$"Auto/Buyers/EDs/Buyers/3/Enabled".button_pressed = value & 1 << 2 > 0
		$"Auto/Buyers/EDs/Buyers/4/Enabled".button_pressed = value & 1 << 3 > 0
		$"Auto/Buyers/EDs/Buyers/5/Enabled".button_pressed = value & 1 << 4 > 0
		$"Auto/Buyers/EDs/Buyers/6/Enabled".button_pressed = value & 1 << 5 > 0
		$"Auto/Buyers/EDs/Buyers/7/Enabled".button_pressed = value & 1 << 6 > 0
		$"Auto/Buyers/EDs/Buyers/8/Enabled".button_pressed = value & 1 << 7 > 0

func EDenabled(which):
	if not $Auto/Buyers/EDs/Enabled.button_pressed: return false
	if get_node("Auto/Buyers/EDs/Buyers/%d/Enabled" % which).\
	button_pressed and \
	get_node("Auto/Buyers/EDs/Buyers/%d/Enabled" % which).visible:
		return true
	return false

@onready var sizechange = [
	$Auto/Buyers/HSeparator, $Auto/Buyers/BigBang, $Auto/Buyers/Galaxy, $Auto/Buyers/Dilation,
	$Auto/Buyers/TimeSpeedLocked, $Auto/Buyers/TimeSpeed, $Auto/Buyers/TD1Locked, $Auto/Buyers/TD1,
	$Auto/Buyers/TD2Locked, $Auto/Buyers/TD2, $Auto/Buyers/TD3Locked, $Auto/Buyers/TD3,
	$Auto/Buyers/TD4Locked, $Auto/Buyers/TD4, $Auto/Buyers/TD5Locked, $Auto/Buyers/TD5,
	$Auto/Buyers/TD6Locked, $Auto/Buyers/TD6, $Auto/Buyers/TD7Locked, $Auto/Buyers/TD7,
	$Auto/Buyers/TD8Locked, $Auto/Buyers/TD8, $Auto/Buyers, $Auto/Buyers/EDs
]

func reset():
	if Globals.Boundlessnesses.to_float() < 2:
		Unlocked = 0
		TSUpgrades = 0
		TDUpgrades = [0, 0, 0, 0, 0, 0, 0, 0]
	RewdUpgrades = 0
	RewdAQups = 0
	DilUpgrades = 0
	GalUpgrades = 0
	BangUpgrades = 0

func TDInterval(which):
	var i = (0.5 + which * 0.1) * (0.6 ** TDUpgrades[which])
	if i < 0.11: return MIN_INTERVAL
	return i
func TSpeedInterval():
	var i = 0.5 * (0.6 ** TSUpgrades)
	if i < 0.11: return MIN_INTERVAL
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
	if i < 0.11: return MIN_INTERVAL
	return i
func DilInterval():
	var i = 4 * (0.6 ** DilUpgrades)
	if i < 0.11: return MIN_INTERVAL
	return i
func GalInterval():
	var i = 10 * (0.6 ** GalUpgrades)
	if i < 0.11: return MIN_INTERVAL
	return i
func BangInterval():
	var i = 60 * (0.6 ** BangUpgrades)
	if i < 0.11: return MIN_INTERVAL
	return i

func TDBulk(which):
	if Globals.Achievemer.is_unlocked(5, 3):
		return 1e9
	elif TDUpgrades[which-1] <= IntervalCap[which-1]:
		return 1
	else:
		return max(2 ** (TDUpgrades[which-1] - IntervalCap[which-1]), 512)

var TSUpgrades   := 0
var TDUpgrades   := [0, 0, 0, 0, 0, 0, 0, 0]
var RewdUpgrades := 0
var RewdAQups    := 0
var DilUpgrades  := 0
var GalUpgrades  := 0
var BangUpgrades := 0
const IntervalCap  := [3, 4, 4, 4, 5, 5, 5, 5]

func improve_interval(which = 0):
	if which == 0:
		Globals.EternityPts.add2self(-(2 ** TSUpgrades))
		TSUpgrades			+= 1
	elif which == 9:
		Globals.EternityPts.add2self(-(2 ** DilUpgrades))
		DilUpgrades			+= 1
	elif which == 10:
		Globals.EternityPts.add2self(-(2 ** GalUpgrades))
		GalUpgrades			+= 1
	elif which == 11:
		Globals.EternityPts.add2self(-(2 ** BangUpgrades))
		BangUpgrades		+= 1
	elif which == 12:
		Globals.EternityPts.add2self(-(2 ** RewdUpgrades))
		RewdUpgrades		+= 1
	else:
		Globals.EternityPts.add2self(-(2 ** TDUpgrades[which-1]))
		TDUpgrades[which-1] += 1

func improve_rewd_accuracy():
	Globals.EternityPts.add2self(-(3 ** RewdAQups))
	RewdAQups += 1

func _process(_delta):
	for i in 8:
		var k = get_node("Auto/Buyers/TD%dLocked" % (i+1))
		k.disabled = Globals.TachTotalBL.less(largenum.new(10).pow2self((i+2) * 10))
		k.text = "%s Tachyon Dimension Autobuyer disabled\n(Requires %s total Tachyons)" % \
		[Globals.ordinal(i+1), largenum.new(10).pow2self((i+2) * 10).to_string()]
	$Auto/Buyers/TimeSpeedLocked.disabled = Globals.TachTotalBL.less(largenum.new(10).pow2self(100))
	$Auto/Buyers/TimeSpeedLocked.text = "Timespeed Autobuyer disabled\n(Requires %s total Tachyons)" % \
	largenum.new(10).pow2self(100).to_string()
	
	for i in $Auto/Buyers.get_children():
		if not (i is Button or i is HSeparator):
			if i.has_node("Mode"): i.get_node("Mode").text = \
				"Complete the challenge to\nchange the mode" if i.get_node("Mode").disabled else (
					(
						"Buys max" if TDBulk(i.name.trim_prefix("TD").to_int()) > 512 else
						"Buys %ss" % Globals.int_to_string(
							Globals.TDHandler.buylim * TDBulk(i.name.trim_prefix("TD").to_int())
						)
					) if i.get_node("Mode").button_pressed else "Buys singles"
				)
			if i.has_node("Enabled"): i.get_node("Enabled").text = \
				"Enabled" if i.get_node("Enabled").button_pressed else "Disabled"
			if i.has_node("Timer"):
				i.get_node("Timer").set_paused(not i.get_node("Enabled").button_pressed)
	
	$Auto/Buyers/Dilation/Enabled.disabled = Globals.Challenge == 10
	if Globals.Challenge == 10:
		$Auto/Buyers/Dilation/Enabled.text = " Disabled (Challenge %s) " % Globals.int_to_string(10)
	
	$Auto/Buyers/Rewind  .visible = Globals.challengeCompleted(10)
	$Auto/Buyers/Dilation.visible = Globals.challengeCompleted(11)
	$Auto/Buyers/Galaxy  .visible = Globals.challengeCompleted(12)
	$Auto/Buyers/BigBang .visible = Globals.challengeCompleted(14)
	$Auto/Buyers/EPMult  .visible = not Globals.Boundlessnesses.less(0)
	if Globals.challengeCompleted(10) and $Auto/Buyers/Rewind/Timer.time_left == 0:
		if $Auto/Buyers/Rewind/Enabled.button_pressed and \
		Globals.TDHandler.rewindNode.score >= RewdAccuracy() and not \
		Globals.TDHandler.rewindBoost().divide(Globals.TDHandler.RewindMult).\
		less($Auto/Buyers/Rewind/Objective.value):
			if buyrewd(): $Auto/Buyers/Rewind/Timer.start(RewdInterval())
	if Globals.challengeCompleted(11) and $Auto/Buyers/Dilation/Timer.time_left == 0:
		if $Auto/Buyers/Dilation/Enabled.button_pressed:
			buydila()
			if Globals.OEUHandler.is_bought(2) and \
			$Auto/Buyers/Dilation/BuyMax/Enabled.button_pressed and \
			Globals.TDilation >= (2 if Globals.Challenge in [6, 16] else 4):
				$Auto/Buyers/Dilation/Timer.start($Auto/Buyers/Dilation/BuyMax.value)
			else:
				$Auto/Buyers/Dilation/Timer.start(DilInterval())
	if Globals.challengeCompleted(12) and $Auto/Buyers/Galaxy/Timer.time_left == 0:
		if $Auto/Buyers/Galaxy/Enabled.button_pressed:
			buygala()
			if Globals.Boundlessnesses.to_float() >= 7 and \
			$Auto/Buyers/Galaxy/BuyMax/Enabled.button_pressed:
				$Auto/Buyers/Galaxy/Timer.start($Auto/Buyers/Dilation/BuyMax.value)
			else:
				$Auto/Buyers/Galaxy/Timer.start(GalInterval())
	if Globals.challengeCompleted(14) and $Auto/Buyers/BigBang/Timer.time_left == 0 and (Globals.progressBL < GL.Progression.Overcome or Globals.Challenge != 0):
		if $Auto/Buyers/BigBang/Enabled.button_pressed:
			bigbang()
			$Auto/Buyers/BigBang/Timer.start(BangInterval())
	if Globals.progressBL >= GL.Progression.Overcome \
	and $Auto/Buyers/BigBang/Enabled.button_pressed:
		if Globals.Boundlessnesses.to_float() < 4 \
		or $Auto/Buyers/BigBang/Amount/OptionButton.selected == 0:
			if BigBangAtEP.less(Formulas.epgained()):
				bigbang()
		elif $Auto/Buyers/BigBang/Amount/OptionButton.selected == 1:
			if BigBangAtEP.less(Formulas.epgained().divide(Globals.EternityPts)):
				bigbang()
		elif $Auto/Buyers/BigBang/Amount/OptionButton.selected == 2:
			if Globals.eternTime >= BigBangAtEP.to_float():
				bigbang()
	
	if Input.is_action_pressed("ToggleAB"):
		for i in range(1, 9):
			if Input.is_action_just_pressed("BuyTD%d" % i):
				get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed = not get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed
		if Input.is_action_just_pressed("BuyTSpeed"):
			$Auto/Buyers/TimeSpeed/Enabled.button_pressed = not $Auto/Buyers/TimeSpeed/Enabled.button_pressed
	
	if not Globals.Achievemer.is_unlocked(4, 3):
		var do = true
		for i in 8:
			if TDUpgrades[i] < IntervalCap[i]:
				do = false
				break
		if do and not $Auto/Buyers/TimeSpeed/Interval.visible:
			Globals.Achievemer.set_unlocked(4, 3)
	
	$Auto/Buyers/TimeSpeed/Interval.visible = TSUpgrades < 3
	$Auto/Buyers/Rewind/Interval.visible  = RewdUpgrades < 7
	$Auto/Buyers/Rewind/Accuracy.visible     = RewdAQups < 8
	$Auto/Buyers/Dilation/Interval.visible = DilUpgrades < 8
	$Auto/Buyers/Galaxy/Interval.visible   = GalUpgrades < 9
	$Auto/Buyers/BigBang/Interval.visible = BangUpgrades < 13
	
	for i in sizechange:
		if i != null: i.custom_minimum_size.x = size.x - 10
	$Auto/Buyers/Rewind/Objective.custom_minimum_size.x = 123
	if not ($Auto/Buyers/Rewind/Interval.visible or $Auto/Buyers/Rewind/Accuracy.visible):
		$Auto/Buyers/Rewind.custom_minimum_size = Vector2(260, 44)
		$Auto/Buyers/Rewind/Objective.\
		set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		$Auto/Buyers/Rewind/Objective.offset_left = -113
	else:
		$Auto/Buyers/Rewind.custom_minimum_size = Vector2(size.x - 10, 45)
		$Auto/Buyers/Rewind/Objective.\
		set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		$Auto/Buyers/Rewind/Objective.anchor_left  = 0.55
		$Auto/Buyers/Rewind/Objective.anchor_right = 0.55
	
	if RewdInterval() == 0:
		$Auto/Buyers/Rewind/RichTextLabel.text = \
		"[center]Rewind Autobuyer\n[font_size=10] Activates instantly\nCurrent accuracy: %s" % \
		Globals.percent_to_string(RewdAccuracy())
	else:
		$Auto/Buyers/Rewind/RichTextLabel.text = \
		"[center]Rewind Autobuyer\n[font_size=10] Activates every %s seconds\nCurrent accuracy: %s" % \
		[Globals.float_to_string(RewdInterval()), Globals.percent_to_string(RewdAccuracy())]
	if Globals.challengeCompleted(13):
		if $Auto/Buyers/Rewind/Interval.visible:
			$Auto/Buyers/Rewind/Interval.disabled = not largenum.two_to_the(RewdUpgrades).less(Globals.EternityPts)
		if $Auto/Buyers/Rewind/Accuracy.visible:
			$Auto/Buyers/Rewind/Accuracy.disabled = not largenum.new(3 ** RewdAQups).less(Globals.EternityPts)
		$Auto/Buyers/Rewind/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** RewdUpgrades, 1)]
		$Auto/Buyers/Rewind/Accuracy.text = "Increase accuracy by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.095, 1),
		Globals.float_to_string(3.0 ** RewdAQups, 1)]
	
	$Auto/Buyers/TimeSpeed/RichTextLabel.text = \
	"[center]Timespeed Autobuyer\n[font_size=10] Activates every %s seconds" % \
	Globals.float_to_string(TSpeedInterval())
	if Globals.challengeCompleted(9):
		$Auto/Buyers/TimeSpeed/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** TSUpgrades, 1)]
		$Auto/Buyers/TimeSpeed/Interval.disabled = not largenum.two_to_the(TSUpgrades).less(Globals.EternityPts)
		$Auto/Buyers/TimeSpeed/Mode.disabled = false
		if $Auto/Buyers/TimeSpeed/Mode.button_pressed:
			$Auto/Buyers/TimeSpeed/Mode.text = "Buys max"
	else:
		$Auto/Buyers/TimeSpeed/Interval.text = "Complete the challenge to\nupgrade the interval"
		$Auto/Buyers/TimeSpeed/Interval.disabled = true
		$Auto/Buyers/TimeSpeed/Mode.disabled = true
		$Auto/Buyers/TimeSpeed/Mode.button_pressed = false
	
	$Auto/Buyers/Dilation/BuyMax.visible = Globals.OEUHandler.is_bought(2)
	$Auto/Buyers/Galaxy/BuyMax.visible = Globals.Boundlessnesses.to_float() >= 7
	
	for i in 8:
		if Globals.challengeCompleted(i+1):
			if TDUpgrades[i] < IntervalCap[i]:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Decrease interval by %s\nCost: %s EP" % \
				[Globals.percent_to_string(0.4, 0),
				Globals.float_to_string(2.0 ** TDUpgrades[i], 1)]
			else:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Increase bulk (%s → %s)\nCost: %s EP" % \
				[Globals.int_to_string(TDBulk(i+1)), Globals.int_to_string(TDBulk(i+1) * 2),
				Globals.float_to_string(2.0 ** TDUpgrades[i], 0)]
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = \
			not largenum.two_to_the(TDUpgrades[i]).less(Globals.EternityPts)
		else:
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = \
			"Complete the challenge to\nupgrade the interval"
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = true
		
		if Globals.Achievemer.is_unlocked(5, 3):
			get_node("Auto/Buyers/TD%d/RichTextLabel" % (i+1)).text = \
			"[center]%s Tachyon Dim Autobuyer\n[font_size=10]Activates every %s seconds" % \
			[Globals.ordinal(i+1), Globals.float_to_string(TDInterval(i))]
		else:
			get_node("Auto/Buyers/TD%d/RichTextLabel" % (i+1)).text = \
			"[center]%s Tachyon Dim Autobuyer\n[font_size=10]Activates every %s seconds\nCurrent bulk: ×%s" % \
			[Globals.ordinal(i+1), Globals.float_to_string(TDInterval(i)), Globals.int_to_string(TDBulk(i+1))]
	
	if not Globals.Achievemer.is_unlocked(5, 2):
		if RewdAQups >= 8 and RewdUpgrades >= 7:
			Globals.Achievemer.set_unlocked(5, 2)
	
	var done = true
	for i in 8:
		if TDUpgrades[i] >= IntervalCap[i] and Globals.Achievemer.is_unlocked(5, 3):
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).hide()
			get_node("Auto/Buyers/TD%d" % (i+1)).custom_minimum_size = Vector2(250, 44)
			get_node("Auto/Buyers/TD%d" % (i+1)).size = Vector2(250, 44)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).custom_minimum_size = Vector2(70, 22)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).\
			set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).position.x = \
			get_node("Auto/Buyers/TD%d/Enabled" % (i+1)).position.x
		else:
			if TDBulk(i+1) < 512 or TDUpgrades[i] < IntervalCap[i]:
				done = false
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).show()
			else:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).hide()
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).custom_minimum_size.x = 217
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).\
			set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).anchor_left  = 0.7
	if done and not Globals.Achievemer.is_unlocked(5, 3):
		Globals.Achievemer.set_unlocked(5, 3)
	
	if TSUpgrades >= 3 and Globals.Achievemer.is_unlocked(5, 3):
		$Auto/Buyers/TimeSpeed.custom_minimum_size = Vector2(250, 44)
		$Auto/Buyers/TimeSpeed.size = Vector2(250, 44)
		$Auto/Buyers/TimeSpeed/Mode.custom_minimum_size = Vector2(70, 22)
		$Auto/Buyers/TimeSpeed/Mode.\
		set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		$Auto/Buyers/TimeSpeed/Mode.position.x = \
		$Auto/Buyers/TimeSpeed/Enabled.position.x
	else:
		$Auto/Buyers/TimeSpeed/Mode.custom_minimum_size.x = 217
		$Auto/Buyers/TimeSpeed/Mode.\
		set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
		$Auto/Buyers/TimeSpeed/Mode.anchor_left  = 0.7
		$Auto/Buyers/TimeSpeed/Mode.size = Vector2(217, 45)
	
	$Auto/Buyers/Dilation/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** DilUpgrades, 1)]
	$Auto/Buyers/Dilation/Interval.disabled = not largenum.two_to_the(DilUpgrades).less(Globals.EternityPts)
	$Auto/Buyers/Dilation/RichTextLabel.text = \
	"[center]Time Dilation Autobuyer\n[font_size=10]Activates every %s seconds" % \
	Globals.float_to_string(DilInterval())
	
	$Auto/Buyers/Galaxy/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** GalUpgrades, 1)]
	$Auto/Buyers/Galaxy/Interval.disabled = not largenum.two_to_the(GalUpgrades).less(Globals.EternityPts)
	$Auto/Buyers/Galaxy/RichTextLabel.text = \
	"[center]Tachyon Galaxy Autobuyer\n[font_size=10]Activates every %s seconds" % \
	Globals.float_to_string(GalInterval())
	
	$Auto/Buyers/BigBang/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** BangUpgrades, 1)]
	$Auto/Buyers/BigBang/Interval.disabled = not largenum.two_to_the(BangUpgrades).less(Globals.EternityPts)
	$Auto/Buyers/BigBang/RichTextLabel.text = \
	"[center]Big Bang Autobuyer"
	if Globals.progressBL < GL.Progression.Overcome:
		$Auto/Buyers/BigBang/RichTextLabel.text += \
		"\n[font_size=10]Activates every %s seconds" % \
		Globals.float_to_string(BangInterval())
	$Auto/Buyers/BigBang/Amount/Label2.text = " (%s)" % BigBangAtEP.to_string()
	$Auto/Buyers/BigBang/Amount.visible = Globals.progressBL >= GL.Progression.Overcome
	if Globals.Boundlessnesses.to_float() < 4:
		$Auto/Buyers/BigBang/Amount/Label.show()
		$Auto/Buyers/BigBang/Amount/OptionButton.hide()
	else:
		$Auto/Buyers/BigBang/Amount/Label.hide()
		$Auto/Buyers/BigBang/Amount/OptionButton.show()
	
	$Auto/Buyers/DupCh .visible = Globals.Boundlessnesses.to_float() >= 8
	$Auto/Buyers/DupInt.visible = Globals.Boundlessnesses.to_float() >= 8
	$Auto/Buyers/DupGal.visible = Globals.Boundlessnesses.to_float() >= 10
	$Auto/Buyers/EDs   .visible = Globals.Boundlessnesses.to_float() >= 11
	for i in $Auto/Buyers/EDs/Buyers.get_children():
		i.visible = Globals.Boundlessnesses.to_float() >= \
		10 + i.name.to_int()
		i.get_node("Label").text = "%s Eternity Dimension\nAutobuyer" % \
		Globals.ordinal(i.name.to_int())
		i.get_node("Enabled").text = "ON" if \
		i.get_node("Enabled").button_pressed else "OFF"
		i.get_node("Enabled").disabled = \
		not $Auto/Buyers/EDs/Enabled.button_pressed
	
	$Auto/Buyers/EDs/Buyers.\
	set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	$Auto/Buyers/EDs/Buyers.\
	position.x -= 10
	$Auto/Buyers/EDs/Buyers.\
	size.x -= 20
	$Auto/Buyers/EDs.custom_minimum_size.y = \
	max($Auto/Buyers/EDs/Buyers.size.y + 16, 67)

func unlock(which):
	if which == 0:
		$Auto/Buyers/TimeSpeed/Timer.start(TSpeedInterval())
		$Auto/Buyers/TimeSpeed.show()
		$Auto/Buyers/TimeSpeedLocked.hide()
	else:
		get_node("Auto/Buyers/TD%d/Timer" % which).start(TDInterval(which - 1))
		get_node("Auto/Buyers/TD%d" % which).show()
		get_node("Auto/Buyers/TD%dLocked" % which).hide()

func buyTSpeed():
	Globals.TDHandler.buytspeed($Auto/Buyers/TimeSpeed/Mode.button_pressed)
	$Auto/Buyers/TimeSpeed/Timer.start(TSpeedInterval())

func buytdim(which):
	if get_node("Auto/Buyers/TD%d/Mode" % which).button_pressed:
		Globals.TDHandler.buydim(which,
			Globals.TDHandler.buylim - \
			Globals.TDHandler.DimPurchase[which-1] % Globals.TDHandler.buylim + \
			Globals.TDHandler.buylim * (TDBulk(which) - 1)
		)
	else:
		Globals.TDHandler.buydim(which, 1)
	get_node("Auto/Buyers/TD%d/Timer" % which).start(TDInterval(which - 1))

func buyrewd():
	if Globals.TDHandler.rewindNode.disabled: return false
	if $Auto/Buyers/Rewind/Enabled.button_pressed:
		Globals.TDHandler.rewind(Globals.TDHandler.rewindNode.score)
	return true

func buydila():
	if Globals.Challenge == 10: return
	if Globals.TDHandler.canDilate \
	and not ($Auto/Buyers/Galaxy/Enabled.button_pressed and Globals.TDHandler.canGalaxy):
		var doit = true
		if $Auto/Buyers/Dilation/Limit/Enabled.button_pressed:
			if Globals.TDilation >= DilLimit:
				doit = false
		if $Auto/Buyers/Dilation/Ignore/Enabled.button_pressed:
			if Globals.TGalaxies >= DilIgnore:
				doit = true
		if doit:
			var dim8 = Globals.TDHandler.DimPurchase[Globals.TDHandler.DimsUnlocked - 1]
			Globals.TDHandler.dilate()
			if Globals.OEUHandler.is_bought(2) and \
			$Auto/Buyers/Dilation/BuyMax/Enabled.button_pressed and \
			Globals.TDilation > (2 if Globals.Challenge in [6, 16] else 4):
				while dim8 >= Globals.TDHandler.dilacost():
					Globals.TDHandler.dilate()

func buygala():
	if Globals.TDHandler.canGalaxy:
		var doit = true
		if $Auto/Buyers/Galaxy/Limit/Enabled.button_pressed:
			if Globals.TGalaxies >= GalLimit:
				doit = false
		if doit:
			var dim8 = Globals.TDHandler.DimPurchase[Globals.TDHandler.DimsUnlocked - 1]
			Globals.TDHandler.galaxy()
			if Globals.Boundlessnesses.to_float() >= 7 and \
			$Auto/Buyers/Galaxy/BuyMax/Enabled.button_pressed:
				while dim8 >= Globals.TDHandler.galacost():
					Globals.TDHandler.galaxy()

func bigbang():
	if Globals.TDHandler.canBigBang:
		Globals.TDHandler.eternity()

func update_bigbang_ep(epgain:String):
	var tree = epgain.split("e")
	var k = largenum.new(0)
	for i in range(tree.size()-1, -1, -1):
		if ";" in tree[i]:
			var j = 0
			var mag = 12.0 ** len(tree[i].split(";")[0])
			var T = tree[i]\
			.replace("X", "↊").replace("T", "↊").replace("A", "↊").replace("τ", "↊")\
			.replace("E", "↋").replace("Ɛ", "↋").replace("B", "↋").replace("ε", "↋")
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
	BigBangAtEP = k
