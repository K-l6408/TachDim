extends Control

const MAXROWS = 20
var loaded_rows = 4
var unlocked : PackedByteArray = []
var achgot : int :
	get:
		var a = 0
		for R in min(MAXROWS, loaded_rows):
			for C in range(1, 9):
				if is_unlocked(R+1, C): a += 1
		return a

func achnames(r, c):
	match r:
		1: match c:
			1: return "Welcome to TachDim!"
			2: return "%s already‽" % Globals.int_to_string(100)
			3: return "Rule of threes or something"
			4: return "ouugbhh"
			5: return "Just a handful"
			6: return "More like SEXTH DIMENSION"
			7: return "No RNG required"
			8: return "Seven %s Nine" % Globals.int_to_string(8).to_pascal_case()
		2: match c:
			1: return "Tier %s-C" % Globals.int_to_string(3)
			2: return "Galaxy %s: the sequel" % Globals.int_to_string(2)
			3: return "Speedometer broke :("
			4: return "CRITICAL HIT!!"
			5: return "Uwa! So Dimensions ♪"
			6: return "You can stop holding M now"
			7: return "Seriously, why?"
			8: return "Popular TV sitcom"
		3: match c:
			1: return "Kinda OP innit"
			2: return "many"
			3: return "Goodnight! :3"
			4: return "I h-eight them ›:("
			5: return "ɘmiT bniwɘЯ"
			6: return "And… time!"
			7: return "Too is two many"
			8: return "(Not quite) Full upgrades!"
		4: match c:
			1: return "unChallenged"
			2: return "Particle Accelerator"
			3: return "Autobuyerpillled Intervalmaxxer"
			4: return "I h-seven them…?"
			5: return "Up and up and up"
			6: return "(Actually) Full upgrades!"
			7: return "A taste of Mastery"
			8: return "I-XV"
	return "TBD"

func achreqs(r, c):
	match r:
		1: return "Buy a %s Tachyon Dimension" % Globals.ordinal(c)
		2: match c:
			1: return "Get a Tachyon Galaxy."
			2: return "Get ANOTHER Tachyon Galaxy."
			3: return "Have %s Time Dilation." % Globals.int_to_string(10)
			4: return "Rewind with near-perfect accuracy." + \
			"\n(Reward: Rewind is stronger, and its multiplier can't go below the current one.)"
			5: return "Have at least %s of all TDs except for the %s." % [
				Globals.float_to_string(10**10), Globals.ordinal(8)
			] + "\n(Reward: All TDs are %s stronger.)" % Globals.percent_to_string(0.1)
			6: return "Unlock all TD autobuyers."
			7: return "Buy a single %s TD when you have over %s of them." % [
				Globals.ordinal(1), largenum.ten_to_the(100).to_string()
			] + "\n(Reward: The %s TD is %s stronger.)" % [Globals.ordinal(1), Globals.percent_to_string(0.5)]
			8: return "Reach Infinite Tachyons." + \
			"\n(Reward: Start with %s Tachyons.)" % Globals.int_to_string(100)
		3: match c:
			1: return "Get any TD multiplier above %s." % largenum.ten_to_the(40)
			2: return "Big Bang %s times." % Globals.int_to_string(10)
			3: return "Keep the game closed for more than %s." % Globals.format_time(3600*6)
			4: return "Eternity with no %s TDs." % Globals.ordinal(8) + \
			"\n(Reward: TDs %s-%s are %s stronger.)" % [
				Globals.int_to_string(1), Globals.int_to_string(7),
				Globals.percent_to_string(.5)
			]
			5: return "Get at least a ×%s multiplier from a single Rewind." % \
			Globals.int_to_string(600)
			6: return "Eternity in under %s.\n(Reward: Start with %s Tachyons.)" % \
			[Globals.format_time(600), Globals.int_to_string(5000)]
			7: return "Eternity with a single Tachyon Galaxy."
			8: return "Purchase the first %s Eternity Upgrades." % Globals.int_to_string(12)
		4: match c:
			1: return "Complete a Challenge."
			2: return "Eternity in under %s.\n(Reward: Start with %s Tachyons.)" % [
				Globals.format_time(60), Globals.float_to_string(5e5)
			]
			3: return "Max the interval for all TD autobuyers, and Timespeed."
			4: return "Eternity without any %s Dimensions." % Globals.ordinal(7)
			5: return "Get to %s Tachyons with less than %s in your current Eternity." % [
				largenum.ten_to_the(100).to_string(), Globals.format_time(30)
			]
			6: return "Purchase %s Eternity Upgrades." % Globals.int_to_string(16) + \
			"\n(Reward: Unlock two more Eternity Upgrades)"
			7: return "Complete Challenge %s." % Globals.int_to_string(15) + \
			"\n(Reward: Gain ×%s more Eternity Points for each C%s completion.)" % [
				Globals.int_to_string(5), Globals.int_to_string(15)
			]
			8: return "Complete all Challenges.\n(Reward: All TDs are %s stronger.)" % \
			Globals.percent_to_string(0.2)
	return "TBD"

func is_unlocked(row, num):
	return (unlocked[row-1] & (2 ** (num - 1)) > 0)

func set_unlocked(row, num, val := true):
	if val:
		unlocked[row-1] |= (1 << (num - 1))
		Globals.notificate(
			"achievement",
			"Achievement unlocked: \"%s\"" % achnames(row, num)
		)
	else:
		unlocked[row-1] &= 255 - (1 << (num - 1))

func _ready():
	unlocked.resize(MAXROWS)
	unlocked.fill(0)
	for i in min(MAXROWS, loaded_rows):
		for j in 8:
			var n : TextureRect = $Achiev.duplicate()
			n.texture = n.texture.duplicate()
			n.texture.region.position = n.texture.region.size * Vector2(j, i)
			n.name = "%dx%d" % [i+1, j+1]
			%GridContainer.add_child(n)
			n.get_node("Label").text = n.name
			n.show()

func _process(_delta):
	for i in range(1, min(MAXROWS, %GridContainer.get_child_count() / 8) + 1):
		for j in range(1, 9):
			%GridContainer.get_node("%dx%d" % [i,j]).self_modulate = \
			Color("9f9") if is_unlocked(i,j) else Color("999")
			%GridContainer.get_node("%dx%d" % [i,j]).tooltip_text = \
			"\"%s\"\n%s" % [achnames(i,j), achreqs(i,j)]
	for i in 8:
		if not is_unlocked(1,i+1):
			if Globals.TDHandler.DimPurchase[i] > 0:
				set_unlocked(1,i+1)
	if not is_unlocked(2, 1):
		if Globals.TGalaxies >= 1:
			set_unlocked(2, 1)
	if not is_unlocked(2, 2):
		if Globals.TGalaxies >= 2:
			set_unlocked(2, 2)
	if not is_unlocked(2, 3):
		if Globals.TDilation >= 10:
			set_unlocked(2, 3)
	if not is_unlocked(2, 5):
		var ok := true
		for i in 7:
			if Globals.TDHandler.DimAmount[i].less(largenum.ten_to_the(10)):
				ok = false
				break
		if ok: set_unlocked(2, 5)
	if not is_unlocked(2, 6):
		if Globals.Automation.Unlocked == 511:
			set_unlocked(2, 6)
	if not is_unlocked(3, 2):
		if not Globals.Eternities.less(10):
			set_unlocked(3, 2)
	if not is_unlocked(3, 8):
		if  Globals.EUHandler.is_bought(4) \
		and Globals.EUHandler.is_bought(8) \
		and Globals.EUHandler.is_bought(12):
			set_unlocked(3, 8)
	if not is_unlocked(4, 1):
		if Globals.CompletedChallenges > 0:
			set_unlocked(4, 1)
	if not is_unlocked(4, 5):
		if Globals.Tachyons.log10() >= 100 and Globals.eternTime < 30:
			set_unlocked(4, 5)
	if not is_unlocked(4, 6):
		if  Globals.EUHandler.is_bought(4) \
		and Globals.EUHandler.is_bought(8) \
		and Globals.EUHandler.is_bought(12)\
		and Globals.EUHandler.is_bought(16):
			set_unlocked(4, 6)
	if not is_unlocked(4, 7):
		if Globals.challengeCompleted(15):
			set_unlocked(4, 7)
	if not is_unlocked(4, 8):
		if Globals.CompletedChallenges == 32767:
			set_unlocked(4, 8)
