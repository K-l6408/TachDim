extends Control

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
						"Buys max" if
						Autobuyers.TDBulk(i.name.trim_prefix("TD").to_int()) == INF else
						"Buys %ss" % Globals.int_to_string(
							TachyonDims.buylim * \
							Autobuyers.TDBulk(i.name.trim_prefix("TD").to_int())
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
	
	
	if Input.is_action_pressed("ToggleAB"):
		for i in range(1, 9):
			if Input.is_action_just_pressed("BuyTD%d" % i):
				get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed = not get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed
		if Input.is_action_just_pressed("BuyTSpeed"):
			$Auto/Buyers/TimeSpeed/Enabled.button_pressed = not $Auto/Buyers/TimeSpeed/Enabled.button_pressed
	
	
	$Auto/Buyers/TimeSpeed/Interval.visible = Autobuyers.TSUpgrades   < 3
	$Auto/Buyers/Rewind/Interval.visible    = Autobuyers.RewdUpgrades < 7
	$Auto/Buyers/Rewind/Accuracy.visible    = Autobuyers.RewdAQups    < 8
	$Auto/Buyers/Dilation/Interval.visible  = Autobuyers.DilUpgrades  < 8
	$Auto/Buyers/Galaxy/Interval.visible    = Autobuyers.GalUpgrades  < 9
	$Auto/Buyers/BigBang/Interval.visible   = Autobuyers.BangUpgrades < 13
	
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
	
	if Autobuyers.RewdInterval() == 0:
		$Auto/Buyers/Rewind/RichTextLabel.text = \
		"[center]Rewind Autobuyer\n[font_size=10] Activates instantly\nCurrent accuracy: %s" % \
		Globals.percent_to_string(Autobuyers.RewdAccuracy())
	else:
		$Auto/Buyers/Rewind/RichTextLabel.text = \
		"[center]Rewind Autobuyer\n[font_size=10] Activates every %s\nCurrent accuracy: %s" % \
		[Globals.format_time(Autobuyers.RewdInterval()),
		Globals.percent_to_string(Autobuyers.RewdAccuracy())]
	
	if Globals.challengeCompleted(13):
		if $Auto/Buyers/Rewind/Interval.visible:
			$Auto/Buyers/Rewind/Interval.disabled = \
			not largenum.two_to_the(Autobuyers.RewdUpgrades).\
			less(Currencies.EternityPts.AMOUNT)
		if $Auto/Buyers/Rewind/Accuracy.visible:
			$Auto/Buyers/Rewind/Accuracy.disabled = \
			not largenum.new(3 ** Autobuyers.RewdAQups).\
			less(Currencies.EternityPts.AMOUNT)
		$Auto/Buyers/Rewind/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** Autobuyers.RewdUpgrades, 1)]
		$Auto/Buyers/Rewind/Accuracy.text = "Increase accuracy by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.095, 1),
		Globals.float_to_string(3.0 ** Autobuyers.RewdAQups, 1)]
	
	$Auto/Buyers/TimeSpeed/RichTextLabel.text = \
	"[center]Timespeed Autobuyer\n[font_size=10] Activates every %s" % \
	Globals.format_time(Autobuyers.TSpeedInterval())
	if Globals.challengeCompleted(9):
		$Auto/Buyers/TimeSpeed/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** Autobuyers.NormUpgrades[8], 1)]
		$Auto/Buyers/TimeSpeed/Interval.disabled = \
		not largenum.two_to_the(Autobuyers.NormUpgrades[8]).\
		less(Currencies.EternityPts.AMOUNT)
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
			if Autobuyers.NormUpgrades[i] < Autobuyers.IntervalCap[i]:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Decrease interval by %s\nCost: %s EP" % \
				[Globals.percent_to_string(0.4, 0),
				Globals.float_to_string(2.0 ** Autobuyers.NormUpgrades[i], 1)]
			else:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Increase bulk (%s → %s)\nCost: %s EP" % \
				[Globals.int_to_string(Autobuyers.TDBulk(i+1)), Globals.int_to_string(Autobuyers.TDBulk(i+1) * 2),
				Globals.float_to_string(2.0 ** Autobuyers.NormUpgrades[i], 0)]
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = \
			not largenum.two_to_the(Autobuyers.NormUpgrades[i]).less(Currencies.EternityPts.AMOUNT)
		else:
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = \
			"Complete the challenge to\nupgrade the interval"
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = true
	
	for i in 8:
		if Globals.Achievemer.is_unlocked(5, 3):
			get_node("Auto/Buyers/TD%d/RichTextLabel" % (i+1)).text = \
			"[center]%s Tachyon Dim Autobuyer\n[font_size=10]Activates every %s" % \
			[Globals.ordinal(i+1), Globals.format_time(Autobuyers.TDInterval(i))]
		else:
			get_node("Auto/Buyers/TD%d/RichTextLabel" % (i+1)).text = \
			"[center]%s Tachyon Dim Autobuyer\n[font_size=10]Activates every %s\nCurrent bulk: ×%s" % \
			[Globals.ordinal(i+1), Globals.format_time(Autobuyers.TDInterval(i)), Globals.int_to_string(Autobuyers.TDBulk(i+1))]
		
		if Autobuyers.NormUpgrades[i] >= Autobuyers.IntervalCap[i] and Globals.Achievemer.is_unlocked(5, 3):
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).hide()
			get_node("Auto/Buyers/TD%d" % (i+1)).custom_minimum_size = Vector2(250, 44)
			get_node("Auto/Buyers/TD%d" % (i+1)).size = Vector2(250, 44)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).custom_minimum_size = Vector2(70, 22)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).\
			set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).position.x = \
			get_node("Auto/Buyers/TD%d/Enabled" % (i+1)).position.x
		else:
			if Autobuyers.TDBulk(i+1) < 512 or Autobuyers.NormUpgrades[i] < Autobuyers.IntervalCap[i]:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).show()
			else:
				get_node("Auto/Buyers/TD%d/Interval" % (i+1)).hide()
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).custom_minimum_size.x = 217
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).\
			set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
			get_node("Auto/Buyers/TD%d/Mode" % (i+1)).anchor_left  = 0.7
	
	if Autobuyers.NormUpgrades[9] >= 3 and Globals.Achievemer.is_unlocked(5, 3):
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
	Globals.float_to_string(2.0 ** Autobuyers.DilUpgrades, 1)]
	$Auto/Buyers/Dilation/Interval.disabled = \
	not largenum.two_to_the(Autobuyers.DilUpgrades).\
	less(Currencies.EternityPts.AMOUNT)
	$Auto/Buyers/Dilation/RichTextLabel.text = \
	"[center]Time Dilation Autobuyer\n[font_size=10]Activates every %s" % \
	Globals.format_time(Autobuyers.DilInterval())
	
	$Auto/Buyers/Galaxy/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** Autobuyers.GalUpgrades, 1)]
	$Auto/Buyers/Galaxy/Interval.disabled = not largenum.two_to_the(Autobuyers.GalUpgrades).less(Currencies.EternityPts.AMOUNT)
	$Auto/Buyers/Galaxy/RichTextLabel.text = \
	"[center]Tachyon Galaxy Autobuyer\n[font_size=10]Activates every %s" % \
	Globals.format_time(Autobuyers.GalInterval())
	
	$Auto/Buyers/BigBang/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** Autobuyers.BangUpgrades, 1)]
	$Auto/Buyers/BigBang/Interval.disabled = not largenum.two_to_the(Autobuyers.BangUpgrades).less(Currencies.EternityPts.AMOUNT)
	$Auto/Buyers/BigBang/RichTextLabel.text = \
	"[center]Big Bang Autobuyer"
	if Globals.progressBL < GL.Progression.Overcome:
		$Auto/Buyers/BigBang/RichTextLabel.text += \
		"\n[font_size=10]Activates every %s" % \
		Globals.format_time(Autobuyers.BangInterval())
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
	if which in [0, 9]:
		$Auto/Buyers/TimeSpeed.show()
		$Auto/Buyers/TimeSpeedLocked.hide()
	else:
		get_node("Auto/Buyers/TD%d" % which).show()
		get_node("Auto/Buyers/TD%dLocked" % which).hide()
