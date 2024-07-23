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

func TDInterval(which):
	var i = (0.5 + which * 0.1) * (0.6 ** TDUpgrades[which])
	if i < 0.11: return MIN_INTERVAL
	return i
func TSpeedInterval():
	var i = 0.5 * (0.6 ** TSUpgrades)
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
	var i = 30 * (0.6 ** BangUpgrades)
	if i < 0.11: return MIN_INTERVAL
	return i

var TSUpgrades  := 0
var TDUpgrades  := [0, 0, 0, 0, 0, 0, 0, 0]
var DilUpgrades := 0
var GalUpgrades := 0
var BangUpgrades := 0
var IntervalCap := [3, 4, 4, 4, 5, 5, 5, 5]

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
	else:
		Globals.EternityPts.add2self(-(2 ** TDUpgrades[which-1]))
		TDUpgrades[which-1] += 1

func _process(_delta):
	for i in 8:
		var k = get_node("Auto/Buyers/TD%dLocked" % (i+1))
		if not Globals.TachTotal.less(largenum.new(10).pow2self((i+2) * 10)) and k.disabled:
			Globals.notificate("autobuyers", Globals.ordinal(i+1) + " Dimension Autobuyer unlocked!")
		k.disabled = Globals.TachTotal.less(largenum.new(10).pow2self((i+2) * 10))
		k.text = "%s Tachyon Dimension Autobuyer disabled\n(Requires %s total Tachyons)" % \
		[Globals.ordinal(i+1), largenum.new(10).pow2self((i+2) * 10).to_string()]
	if not Globals.TachTotal.less(largenum.new(10).pow2self(100)) and $Auto/Buyers/TimeSpeedLocked.disabled:
		Globals.notificate("autobuyers", "Timespeed Autobuyer unlocked!")
	$Auto/Buyers/TimeSpeedLocked.disabled = Globals.TachTotal.less(largenum.new(10).pow2self(100))
	$Auto/Buyers/TimeSpeedLocked.text = "Timespeed Autobuyer disabled\n(Requires %s total Tachyons)" % \
	largenum.new(10).pow2self(100).to_string()
	
	for i in $Auto/Buyers.get_children():
		if not (i is Button or i is HSeparator):
			if i.has_node("Mode"): i.get_node("Mode").text = \
				"Complete the challenge to\nchange the mode" if i.get_node("Mode").disabled else (
					("Buys %ss" % Globals.int_to_string(Globals.TDHandler.buylim)) if \
					i.get_node("Mode").button_pressed else "Buys singles"
				)
			i.get_node("Enabled").text = \
				"Enabled" if i.get_node("Enabled").button_pressed else "Disabled"
			i.get_node("Timer").set_paused(not i.get_node("Enabled").button_pressed)
	
	if Globals.Challenge == 10:
		$Auto/Buyers/Dilation/Enabled.disabled = true
		$Auto/Buyers/Dilation/Enabled.text = " Disabled (Challenge %s) " % Globals.int_to_string(10)
	
	$Auto/Buyers/Dilation.visible = Globals.challengeCompleted(11)
	$Auto/Buyers/Galaxy  .visible = Globals.challengeCompleted(12)
	$Auto/Buyers/BigBang .visible = Globals.challengeCompleted(14)
	if Globals.challengeCompleted(11) and $Auto/Buyers/Dilation/Timer.time_left == 0:
		if $Auto/Buyers/Dilation/Enabled.button_pressed: $Auto/Buyers/Dilation/Timer.start()
	if Globals.challengeCompleted(12) and $Auto/Buyers/Galaxy/Timer.time_left == 0:
		if $Auto/Buyers/Galaxy/Enabled.button_pressed: $Auto/Buyers/Galaxy/Timer.start()
	if Globals.challengeCompleted(14) and $Auto/Buyers/BigBang/Timer.time_left == 0:
		if $Auto/Buyers/BigBang/Enabled.button_pressed: $Auto/Buyers/BigBang/Timer.start()
	
	if Input.is_action_pressed("ToggleAB"):
		for i in range(1, 9):
			if Input.is_action_just_pressed("BuyTD%d" % i):
				get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed = not get_node("Auto/Buyers/TD%d/Enabled" % i).button_pressed
		if Input.is_action_just_pressed("BuyTSpeed"):
			$Auto/Buyers/TimeSpeed/Enabled.button_pressed = not $Auto/Buyers/TimeSpeed/Enabled.button_pressed
	
	$Auto/Buyers/TimeSpeed/RichTextLabel.text = \
	"[center]Timespeed Autobuyer\n[font_size=10] Activates every %s seconds\nCurrent bulk: ×1" % \
	Globals.float_to_string(TSpeedInterval())
	if Globals.challengeCompleted(9):
		$Auto/Buyers/TimeSpeed/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** TSUpgrades, 0)]
		$Auto/Buyers/TimeSpeed/Interval.disabled = Globals.EternityPts.less(2 ** TSUpgrades)
		$Auto/Buyers/TimeSpeed/Mode.disabled = false
		if $Auto/Buyers/TimeSpeed/Mode.button_pressed:
			$Auto/Buyers/TimeSpeed/Mode.text = "Buys max"
	else:
		$Auto/Buyers/TimeSpeed/Interval.disabled = true
		$Auto/Buyers/TimeSpeed/Mode.disabled = true
		$Auto/Buyers/TimeSpeed/Mode.button_pressed = false
	for i in 8:
		if Globals.challengeCompleted(i+1):
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Decrease interval by %s\nCost: %s EP" % \
			[Globals.percent_to_string(0.4, 0),
			Globals.float_to_string(2.0 ** TDUpgrades[i], 0)]
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = Globals.EternityPts.less(2 ** TDUpgrades[i])
		else:
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).text = "Complete the challenge to\nupgrade the interval"
			get_node("Auto/Buyers/TD%d/Interval" % (i+1)).disabled = true
		
		get_node("Auto/Buyers/TD%d/RichTextLabel" % (i+1)).text = \
		"[center]%s Tachyon Dim Autobuyer\n[font_size=10]Activates every %s seconds\nCurrent bulk: ×1" % \
		[Globals.ordinal(i+1), Globals.float_to_string(TDInterval(i))]
	
	$Auto/Buyers/Dilation/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** DilUpgrades, 0)]
	$Auto/Buyers/Dilation/Interval.disabled = Globals.EternityPts.less(2 ** DilUpgrades)
	$Auto/Buyers/Dilation/RichTextLabel.text = \
	"[center]Time Dilation Autobuyer\n[font_size=10]Activates every %s seconds\nCurrent bulk: ×1" % \
	Globals.float_to_string(DilInterval())
	
	$Auto/Buyers/Galaxy/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** GalUpgrades, 0)]
	$Auto/Buyers/Galaxy/Interval.disabled = Globals.EternityPts.less(2 ** GalUpgrades)
	$Auto/Buyers/Galaxy/RichTextLabel.text = \
	"[center]Tachyon Galaxy Autobuyer\n[font_size=10]Activates every %s seconds\nCurrent bulk: ×1" % \
	Globals.float_to_string(GalInterval())
	
	$Auto/Buyers/BigBang/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
	[Globals.percent_to_string(0.4, 0),
	Globals.float_to_string(2.0 ** BangUpgrades, 0)]
	$Auto/Buyers/BigBang/Interval.disabled = Globals.EternityPts.less(2 ** BangUpgrades)
	$Auto/Buyers/BigBang/RichTextLabel.text = \
	"[center]Big Bang Autobuyer\n[font_size=10]Activates every %s seconds\nCurrent bulk: ×1" % \
	Globals.float_to_string(BangInterval())

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
			Globals.TDHandler.DimPurchase[which-1] % Globals.TDHandler.buylim)
	else:
		Globals.TDHandler.buydim(which, 1)
	get_node("Auto/Buyers/TD%d/Timer" % which).start(TDInterval(which - 1))

func buydila():
	if  Globals.TDHandler.canDilate:
		var doit = true
		if $Auto/Buyers/Dilation/Limit/Enabled.button_pressed:
			if Globals.TDilation >= DilLimit:
				doit = false
		if $Auto/Buyers/Dilation/Ignore/Enabled.button_pressed:
			if Globals.TGalaxies >= DilIgnore:
				doit = true
		if doit: Globals.TDHandler.dilate()
		
		$Auto/Buyers/Dilation/Timer.start(DilInterval())

func buygala():
	if Globals.TDHandler.canGalaxy:
		var doit = true
		if $Auto/Buyers/Galaxy/Limit/Enabled.button_pressed:
			if Globals.TGalaxies >= GalLimit:
				doit = false
		if doit: Globals.TDHandler.galaxy()
		$Auto/Buyers/Galaxy/Timer.start(GalInterval())

func bigbang():
	if Globals.TDHandler.canBigBang:
		Globals.TDHandler.eternity()
		$Auto/Buyers/BigBang/Timer.start(BangInterval())
