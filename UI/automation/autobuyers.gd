extends VBoxContainer

const MIN_INTERVAL = 0.1

var Unlocked :
	get:
		var UL = 0
		for i in 8:
			if not get_node("TD%d/Timer" % (i + 1)).is_stopped():
				UL += 2 ** i
		return UL
	set(value):
		var UL = value
		Unlocked = value
		for i in 8:
			if UL & 1:
				unlock(i + 1)
			else:
				get_node("TD%d/Timer" % (i + 1)).stop()
				get_node("TD%d" % (i + 1)).hide()
				get_node("TD%dLocked" % (i + 1)).show()
			UL >>= 1
var TSpeedUnlocked : bool = false :
	get:
		return $TimeSpeed.visible
	set(value):
		if value:
			unlock(0)
		else:
			$TimeSpeed/Timer.stop()
			$TimeSpeed.hide()
			$TimeSpeedLocked.show()
var TDModes :
	get:
		return (
			int($TD1/Mode.button_pressed) * 1 +
			int($TD2/Mode.button_pressed) * 2 +
			int($TD3/Mode.button_pressed) * 4 +
			int($TD4/Mode.button_pressed) * 8 +
			int($TD5/Mode.button_pressed) * 16 +
			int($TD6/Mode.button_pressed) * 32 +
			int($TD7/Mode.button_pressed) * 64 +
			int($TD8/Mode.button_pressed) * 128
		)
	set(value):
		$TD1/Mode.button_pressed = value & 1 << 0 > 0
		$TD2/Mode.button_pressed = value & 1 << 1 > 0
		$TD3/Mode.button_pressed = value & 1 << 2 > 0
		$TD4/Mode.button_pressed = value & 1 << 3 > 0
		$TD5/Mode.button_pressed = value & 1 << 4 > 0
		$TD6/Mode.button_pressed = value & 1 << 5 > 0
		$TD7/Mode.button_pressed = value & 1 << 6 > 0
		$TD8/Mode.button_pressed = value & 1 << 7 > 0
var TDEnabl :
	get:
		return (
			int($TD1/Enabled.button_pressed) * 1 +
			int($TD2/Enabled.button_pressed) * 2 +
			int($TD3/Enabled.button_pressed) * 4 +
			int($TD4/Enabled.button_pressed) * 8 +
			int($TD5/Enabled.button_pressed) * 16 +
			int($TD6/Enabled.button_pressed) * 32 +
			int($TD7/Enabled.button_pressed) * 64 +
			int($TD8/Enabled.button_pressed) * 128
		)
	set(value):
		$TD1/Enabled.button_pressed = value & 1 << 0 > 0
		$TD2/Enabled.button_pressed = value & 1 << 1 > 0
		$TD3/Enabled.button_pressed = value & 1 << 2 > 0
		$TD4/Enabled.button_pressed = value & 1 << 3 > 0
		$TD5/Enabled.button_pressed = value & 1 << 4 > 0
		$TD6/Enabled.button_pressed = value & 1 << 5 > 0
		$TD7/Enabled.button_pressed = value & 1 << 6 > 0
		$TD8/Enabled.button_pressed = value & 1 << 7 > 0

func TDInterval(which):
	var i = (0.5 + which * 0.1) * (0.6 ** TDUpgrades[which])
	if i < 0.11: return MIN_INTERVAL
	return i
func TSpeedInterval():
	var i = 0.5 * (0.6 ** TSUpgrades)
	if i < 0.11: return MIN_INTERVAL
	else:		return i
var TSUpgrades  := 0
var TDUpgrades  := [0, 0, 0, 0, 0, 0, 0, 0]
var IntervalCap := [3, 4, 4, 4, 5, 5, 5, 5]

func improve_interval(which = 0):
	if which == 0:	TSUpgrades			+= 1
	else:			TDUpgrades[which-1] += 1

func _process(_delta):
	for i in 8:
		var k = get_node("TD%dLocked" % (i+1))
		if not Globals.TachTotal.less(largenum.new(10).pow2self((i+2) * 10)) and k.disabled:
			Globals.notificate("autobuyers", Globals.ordinal(i+1) + " Dimension Autobuyer unlocked!")
		k.disabled = Globals.TachTotal.less(largenum.new(10).pow2self((i+2) * 10))
		k.text = "%s Tachyon Dimension Autobuyer disabled\n(Requires %s total Tachyons)" % \
		[Globals.ordinal(i+1), largenum.new(10).pow2self((i+2) * 10).to_string()]
	if not Globals.TachTotal.less(largenum.new(10).pow2self(100)) and $TimeSpeedLocked.disabled:
		Globals.notificate("autobuyers", "Timespeed Autobuyer unlocked!")
	$TimeSpeedLocked.disabled = Globals.TachTotal.less(largenum.new(10).pow2self(100))
	$TimeSpeedLocked.text = "Timespeed Autobuyer disabled\n(Requires %s total Tachyons)" % \
	largenum.new(10).pow2self(100).to_string()
	
	for i in get_children():
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
		$Dilation/Enabled.disabled = true
		$Dilation/Enabled.text = " Disabled (Challenge %s) " % Globals.int_to_string(10)
	
	if Input.is_action_pressed("ToggleAB"):
		for i in range(1, 9):
			if Input.is_action_just_pressed("BuyTD%d" % i):
				get_node("TD%d/Enabled" % i).button_pressed = not get_node("TD%d/Enabled" % i).button_pressed
		if Input.is_action_just_pressed("BuyTSpeed"):
			$TimeSpeed/Enabled.button_pressed = not $TimeSpeed/Enabled.button_pressed
	
	$TimeSpeed/RichTextLabel.text = \
	"[center]Timespeed Autobuyer\n[font_size=10] Activates every %s seconds\nCurrent bulk: ×1" % \
	Globals.float_to_string(TSpeedInterval())
	if Globals.challengeCompleted(9):
		$TimeSpeed/Interval.text = "Decrease interval by %s\nCost: %s EP" % \
		[Globals.percent_to_string(0.4, 0),
		Globals.float_to_string(2.0 ** TSUpgrades, 0)]
		$TimeSpeed/Interval.disabled = Globals.EternityPts.less(2 ** TSUpgrades)
		$TimeSpeed/Mode.disabled = false
		if $TimeSpeed/Mode.button_pressed:
			$TimeSpeed/Mode.text = "Buys max"
	else:
		$TimeSpeed/Interval.disabled = true
		$TimeSpeed/Mode.disabled = true
		$TimeSpeed/Mode.button_pressed = false
	for i in 8:
		if Globals.challengeCompleted(i+1):
			get_node("TD%d/Interval" % (i+1)).text = "Decrease interval by %s\nCost: %s EP" % \
			[Globals.percent_to_string(0.4, 0),
			Globals.float_to_string(2.0 ** TDUpgrades[i], 0)]
			get_node("TD%d/Interval" % (i+1)).disabled = Globals.EternityPts.less(2 ** TDUpgrades[i])
		else:
			get_node("TD%d/Interval" % (i+1)).text = "Complete the challenge to\nupgrade the interval"
			get_node("TD%d/Interval" % (i+1)).disabled = true
		
		get_node("TD%d/RichTextLabel" % (i+1)).text = \
		"[center]%s Tachyon Dim Autobuyer\n[font_size=10] Activates every %s seconds\nCurrent bulk: ×1" % \
		[Globals.ordinal(i+1), Globals.float_to_string(TDInterval(i))]

func unlock(which):
	if which == 0:
		$TimeSpeed/Timer.start(TSpeedInterval())
		$TimeSpeed.show()
		$TimeSpeedLocked.hide()
	else:
		get_node("TD%d/Timer" % which).start(TDInterval(which - 1))
		get_node("TD%d" % which).show()
		get_node("TD%dLocked" % which).hide()

func buyTSpeed():
	Globals.TDHandler.buytspeed($TimeSpeed/Mode.button_pressed)
	$TimeSpeed/Timer.start(TSpeedInterval())

func buytdim(which):
	if get_node("TD%d/Mode" % which).button_pressed:
		Globals.TDHandler.buydim(which, 
			Globals.TDHandler.buylim - \
			Globals.TDHandler.DimPurchase[which-1] % Globals.TDHandler.buylim)
	else:
		Globals.TDHandler.buydim(which, 1)
	get_node("TD%d/Timer" % which).start(TDInterval(which - 1))
