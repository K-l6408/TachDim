extends Control

@onready var dims : Array[HBoxContainer] = [null,
	%Dimensions/Dimension1,
	%Dimensions/Dimension2,
	%Dimensions/Dimension3,
	%Dimensions/Dimension4,
	%Dimensions/Dimension5,
	%Dimensions/Dimension6,
	%Dimensions/Dimension7,
	%Dimensions/Dimension8
]
@onready var rewindNode = %TopButtons/Rewind

var DimAmount : Array[largenum] = [
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
]
var DimPurchase : Array[int] = [0,0,0,0,0,0,0,0]
const TSpeedScaleStart := 305

var DistantScaling :
	get: return 75

var TSpeedBoost := largenum.new(1.13)
var TSpeedCount := 0

var DimsUnlocked := 4
var TCperS := largenum.new(0)
var BuyMax : bool

var C2Multiplier := 1.0
var C14Divisor := 1.0
var C10Power := 0.0
func C10Score():
	return sin(Time.get_ticks_msec() / 1000.0)

var RewindMult := largenum.new(1)

var canDilate :
	get: return (not %Prestiges/DiButton.disabled) and $VSplitContainer.visible
var canGalaxy :
	get:
		if Globals.Challenge == 22: return false
		return (not %Prestiges/GaButton.disabled) and $VSplitContainer.visible
var canBigBang:
	get:
		if Globals.Challenge > 15:
			return Globals.ECTargets[Globals.Challenge - 16].less(topTachyonsInEternity)
		var logfinity = 2048 if Globals.Challenge == 15 else 1024
		return (Globals.Tachyons.log2() >= logfinity) or (topTachyonsInEternity.log2() >= logfinity)
var topTachyonsInEternity := largenum.new(0)

var buylim : int :
	get:
		if Globals.Challenge == 5 or Globals.Challenge == 16:	return 15
		else:													return 10
var latest_purchased = 1

func tspcost():
	var start = 1
	var increase = 1
	if Globals.Challenge == 5 or Globals.Challenge == 16:
		increase += 1 - GL.LOG2 / GL.LOG10
	
	var purchase : int = TSpeedCount
	
	var costlog = start + increase * purchase
	
	if costlog >= 308.2547156:
		var scalingamount = log(10 - Globals.OEUHandler.TSpScBought) / GL.LOG10
		var scaling : int = purchase - (308.2547156 - start) / increase
		costlog += scaling * (scaling + 1) * scalingamount / 2
	
	return largenum.ten_to_the(costlog)

func dimcost(which):
	var start = [
		1, 2, 4, 6,
		9,13,18,24
	][which - 1]
	var increase = [
		3, 4, 5, 6,
		8,10,12,15
	][which - 1]
	if Globals.Challenge == 1 or Globals.Challenge == 16:
		increase = [
			4, 6, 8, 10,
			13,15,17,20
		][which - 1]
	var purchase : int = DimPurchase[which - 1] / buylim
	
	var costlog = start + increase * purchase
	
	if costlog >= 308.2547156:
		var scalingamount = log(10 - Globals.OEUHandler.TDmScBought) / GL.LOG10
		var scaling : int = purchase - (308.2547156 - start) / increase
		costlog += scaling * (scaling + 1) * scalingamount / 2
	
	return largenum.ten_to_the(costlog)

func updateTSpeed():
	var GalaxyBoost = 0.975
	var GalaxyMult = 1
	if Globals.EUHandler.is_bought(8): GalaxyMult *= 2
	if Globals.OEUHandler.is_bought(3): GalaxyMult *= 1.4
	if Globals.ECCompleted(4): GalaxyMult *= 1.15
	if Globals.Challenge == 12:
		TSpeedBoost = largenum.new(1.10)
	else:
		TSpeedBoost = largenum.new(1.13)
	TSpeedBoost.div2self(largenum.new(GalaxyBoost).power(
		(Globals.TGalaxies + Globals.DupHandler.dupGalaxies) * GalaxyMult
	))

func rewind(score:float):
	if not (
		Globals.Achievemer.is_unlocked(3, 5) or
		rewindBoost(score).divide(RewindMult).less(600)):
			Globals.Achievemer.set_unlocked(3, 5)
	RewindMult = rewindBoost(score)
	if Globals.Challenge == 8:
		var RM = RewindMult
		var TS = TSpeedCount
		reset(0)
		RewindMult = RM
		TSpeedCount = TS
	else:
		for i in 7:
			DimAmount[i].pow2self(1 - score)
			if DimAmount[i].less(DimPurchase[i]):
				DimAmount[i] = largenum.new(DimPurchase[i])

func rewindBoost(score := 1.0) -> largenum:
	var RBoost : largenum
	if Globals.Challenge == 8:
		RBoost = DimAmount[0].power(0.1)
	elif Globals.OEUHandler.is_bought(6):
		RBoost = DimAmount[0].power(0.05)
	else:
		RBoost = largenum.new(DimAmount[0].log10() ** 1.5 / 10)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(2)
	
	if Globals.Achievemer.is_unlocked(5, 4): RBoost.pow2self(1.2)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.div2self(RewindMult)
	RBoost.pow2self(score)
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(RewindMult)
	
	return RBoost

func buydim(which, bulkoverride := 0):
	if which > 1:
		if DimAmount[which - 2].exponent == -INF:
			return
	while true:
		if which > DimsUnlocked:
			return
		var bulk :int= 1
		if Globals.Tachyons.exponent - dimcost(which).exponent < 62:
			if (
				(%TopButtons/BuyMode.button_pressed
				and not Input.is_action_pressed("BuyOne"))
				or bulkoverride != 0
			):
				if Globals.Tachyons.divide(dimcost(which)).to_float() >= buylim:
					bulk = buylim - DimPurchase[which-1] % buylim
				else:
					bulk = min(
						(Globals.Tachyons.divide(dimcost(which))).to_float(),
						buylim - DimPurchase[which-1] % buylim
					)
		else:
			bulk = buylim - DimPurchase[which-1] % buylim
		
		if bulk < 1:
			return
		
		if bulkoverride > 0:
			if min(bulkoverride, buylim - DimPurchase[which-1] % buylim) > bulk:
				return
			bulk = min(bulk, bulkoverride)
		
		if Globals.Tachyons.exponent - dimcost(which).exponent < 62:
			Globals.Tachyons.add2self(dimcost(which).neg().mult2self(bulk))
		DimPurchase[which-1] += bulk
		if DimAmount[which-1].exponent < 100:
			DimAmount[which-1].add2self(bulk)
		if not Globals.Achievemer.is_unlocked(2, 7):
			if bulk == 1 and which == 1 and DimAmount[which-1].log10() >= 100:
				Globals.Achievemer.set_unlocked(2, 7)
		
		if Globals.Challenge == 2 or Globals.Challenge == 16: C2Multiplier = 0.0
		if Globals.Challenge == 7:
			for i in which - 1: DimAmount[i] = largenum.new(DimPurchase[i])
		if Globals.Challenge == 14 or Globals.Challenge == 16: C14Divisor = 1.0
		latest_purchased = which
		
		if bulkoverride >= buylim:
			bulkoverride -= buylim
		else:
			return

func buytspeed(maxm:bool):
	if Globals.Challenge == 20: return
	while tspcost().less(Globals.Tachyons):
		if Globals.Tachyons.exponent - tspcost().exponent < 62:
			Globals.Tachyons.add2self(tspcost().neg())
			if Globals.Tachyons.sign < 0:
				Globals.Tachyons.add2self(tspcost())
				return
		TSpeedCount += 1
		if Globals.Challenge == 2 or Globals.Challenge == 16: C2Multiplier = 0.0
		if Globals.Challenge == 14:  C14Divisor = 1.0
		if not maxm: break

func antisoftlock():
	reset(0)
	if Globals.TDilation > -3:
		Globals.TDilation -= 1

func dilate():
	reset(0)
	Globals.TDilation += 1
	if Globals.Challenge == 10:
		C10Power += 1 - abs(C10Score())
	if  Globals.progress   < Globals.Progression.Dilation:
		Globals.progress   = Globals.Progression.Dilation
	if  Globals.progressBL < Globals.Progression.Dilation:
		Globals.progressBL = Globals.Progression.Dilation

func galaxy():
	if Globals.Challenge == 22: return
	Globals.TGalaxies += 1
	reset(1)
	if  Globals.progress   < Globals.Progression.Galaxy:
		Globals.progress   = Globals.Progression.Galaxy
	if  Globals.progressBL < Globals.Progression.Galaxy:
		Globals.progressBL = Globals.Progression.Galaxy

func eternity(resetchallenge := true):
	if resetchallenge:
		if Globals.Challenge != 0 and Globals.Challenge <= 15:
			Globals.CompletedChallenges |= 1 << (Globals.Challenge - 1)
			if  Globals.challengeTimes[Globals.Challenge - 1] > Globals.eternTime \
			or  Globals.challengeTimes[Globals.Challenge - 1] < 0:
				Globals.challengeTimes[Globals.Challenge - 1] = Globals.eternTime
		if Globals.Challenge > 15:
			Globals.CompletedECs |= 1 << (Globals.Challenge - 16)
			if Globals.ECTimes.size() < Globals.Challenge - 15:
				Globals.ECTimes.append(-1)
			if  Globals.ECTimes[Globals.Challenge - 16] > Globals.eternTime \
			or  Globals.ECTimes[Globals.Challenge - 16] < 0:
				Globals.ECTimes[Globals.Challenge - 16] = Globals.eternTime
	
	var epgain = Formulas.epgained()
	var etgain = 1
	
	if "2×1" in Globals.Studies.purchased:
		etgain = max(Globals.TDilation, 1)
	
	Globals.EternityPts.add2self(epgain)
	Globals.Eternities .add2self(etgain)
	
	if  Globals.progress   < Globals.Progression.Eternity:
		Globals.progress   = Globals.Progression.Eternity
	if  Globals.progressBL < Globals.Progression.Eternity:
		Globals.progressBL = Globals.Progression.Eternity
	
	if Globals.fastestEtern.time > Globals.eternTime \
	or Globals.fastestEtern.time < 0:
		Globals.fastestEtern.time		= Globals.eternTime
		Globals.fastestEtern.currency	= epgain
		Globals.fastestEtern.amount		= largenum.new(etgain)
	
	if not Globals.Achievemer.is_unlocked(2, 8):
		Globals.Achievemer.set_unlocked(2, 8)
	if DimPurchase[7] == 0:
		if not Globals.Achievemer.is_unlocked(3, 4):
			Globals.Achievemer.set_unlocked(3, 4)
		if not Globals.Achievemer.is_unlocked(4, 4) and DimPurchase[6] == 0:
			Globals.Achievemer.set_unlocked(4, 4)
	if not Globals.Achievemer.is_unlocked(3, 6) and Globals.eternTime <= 600:
		Globals.Achievemer.set_unlocked(3, 6)
	if not Globals.Achievemer.is_unlocked(4, 2) and Globals.eternTime <= 60:
		Globals.Achievemer.set_unlocked(4, 2)
	if not Globals.Achievemer.is_unlocked(6, 4) and Globals.eternTime <= 0.5:
		Globals.Achievemer.set_unlocked(6, 4)
	if not Globals.Achievemer.is_unlocked(3, 7) and Globals.TGalaxies == 1:
		Globals.Achievemer.set_unlocked(3, 7)
	if not Globals.Achievemer.is_unlocked(6, 2) and Globals.TGalaxies == 0 and \
	Globals.TDilation <= 0:
		Globals.Achievemer.set_unlocked(6, 2)
	if not Globals.Achievemer.is_unlocked(6, 6) and Globals.TGalaxies == 0 and \
	Globals.TDilation <= -3:
		Globals.Achievemer.set_unlocked(6, 6)
	if not Globals.Achievemer.is_unlocked(7, 5) and epgain.log10() >= 200:
		Globals.Achievemer.set_unlocked(7, 5)
	
	Globals.last10etern.insert(0, Globals.PrestigeData.new(
		Globals.eternTime, epgain, etgain
	))
	if Globals.last10etern.size() > 10:
		Globals.last10etern.resize(10)
	
	await get_tree().process_frame
	reset(2, resetchallenge)
	updateTSpeed()
	Globals.animation("bang")

func reset(level := 0, challengeReset := true):
	if level >= 2 and challengeReset: Globals.Challenge = 0
	if Globals.Challenge == 2  or Globals.Challenge == 16: C2Multiplier = 1.0
	if Globals.Challenge == 14 or Globals.Challenge == 16:  C14Divisor = 1.0
	if   Globals.Achievemer.is_unlocked(6,4):
		Globals.Tachyons = largenum.ten_to_the(25.6989)
	elif Globals.Achievemer.is_unlocked(4,2):
		Globals.Tachyons = largenum.ten_to_the(5.6989)
	elif Globals.Achievemer.is_unlocked(3,6):
		Globals.Tachyons = largenum.ten_to_the(3.6989)
	elif Globals.Achievemer.is_unlocked(2,8):
		Globals.Tachyons = largenum.ten_to_the(2)
	else:
		Globals.Tachyons = largenum.ten_to_the(1)
	DimPurchase = [0,0,0,0,0,0,0,0]
	for i in DimAmount:
		i.exponent = -INF # set to zero
		i.fix_mantissa()
	TSpeedCount = 0
	RewindMult = largenum.new(1)
	if level >= 1:
		if   Globals.Challenge == 11 or Globals.Challenge == 16:
			Globals.TDilation = -3
		elif Globals.Challenge != 0:
			Globals.TDilation = 0
		elif Globals.EUHandler.is_bought(17):
			Globals.TDilation = 5
		elif Globals.EUHandler.is_bought(16):
			Globals.TDilation = 4
		elif Globals.EUHandler.is_bought(15):
			Globals.TDilation = 3
		elif Globals.EUHandler.is_bought(14):
			Globals.TDilation = 2
		elif Globals.EUHandler.is_bought(13):
			Globals.TDilation = 1
		else:
			Globals.TDilation = 0
		if Globals.Challenge == 10: C10Power = 0
	if level >= 2:
		if Globals.Challenge != 0:            Globals.TGalaxies = 0
		elif Globals.EUHandler.is_bought(17): Globals.TGalaxies = 1
		else:                                 Globals.TGalaxies = 0
		if Globals.Challenge == 10:
			%Prestiges/DiButton.material = rewindNode.material.duplicate()
			%Prestiges/DiButton.material.set_shader_parameter("pixelsize", 1./250.)
		else:
			%Prestiges/DiButton.material = null
		Globals.eternTime = 0
		topTachyonsInEternity = largenum.new(0)
		emit_signal("eternitied")
	updateTSpeed()

func _process(delta):
	
	var logfinity = 2048 if Globals.Challenge == 15 else 1024
	
	if canBigBang and Input.is_action_pressed("BBang"):
		eternity()
	
	if topTachyonsInEternity.less(Globals.Tachyons):
		topTachyonsInEternity = largenum.new(Globals.Tachyons)
	
	if Globals.progressBL < GL.Progression.Overcome or \
	(Globals.Challenge != 0 and Globals.Challenge <= 15):
		$VSplitContainer.visible = (Globals.Tachyons.log2() <= logfinity)
		$ETERNITY.visible        = (Globals.Tachyons.log2() >= logfinity)
		
		if canBigBang:
			custom_minimum_size.y = $ETERNITY.size.y
		
		if Globals.Tachyons.log2() >= logfinity:
			Globals.Tachyons.exponent = logfinity
			Globals.Tachyons.mantissa = (1 << 62)
			return
	else:
		$VSplitContainer.visible = true
		$ETERNITY.visible = false
	custom_minimum_size.y = $VSplitContainer.size.y
	
	if Globals.Challenge == 6 or Globals.Challenge == 16:
		DimsUnlocked = min(Globals.TDilation + 4, 6)
	else:
		DimsUnlocked = min(Globals.TDilation + 4, 8)
	for k in range(1, len(dims)):
		var i = dims[k]
		if i == null: continue
		if k > DimsUnlocked:	i.hide()
		else:					i.show()
		i.get_node("Buy").tooltip_text = "Purchased %s time%s" % \
		[Globals.int_to_string(DimPurchase[k-1]), "" if DimPurchase[k-1] == 1 else "s"]
		var buyable = (Globals.Tachyons.divide(dimcost(k))).to_float()
		if abs(buyable) > buylim:
			buyable = buylim
		buyable = int(buyable)
		i.get_node("Buy/Progress").value = int(buyable)
		i.get_node("Buy/Progress").max_value = buylim - DimPurchase[k-1] % buylim
		i.get_node("Buy").disabled = not dimcost(k).less(Globals.Tachyons)
		if k < 8:
			i.get_node("A&G/Amount").text = DimAmount[k-1].to_string().trim_suffix(".00").trim_suffix(";00")
		else:
			i.get_node("A&G/Amount").text = Globals.int_to_string(DimPurchase[k-1])
		i.get_node("Buy").text = "Buy %s\nCost: %s TC" % [
			Globals.int_to_string(min(buyable, buylim - DimPurchase[k-1] % buylim)),
			dimcost(k).multiply(min(max(buyable, 1), buylim - DimPurchase[k-1] % buylim)).to_string()
		]
	if Globals.Challenge == 20:
		%TopButtons/Timespeed.disabled = true
		%TopButtons/Timespeed/BuyMax.disabled = true
		%TopButtons/Timespeed.text = "Timespeed disabled (EC5)"
	else:
		%TopButtons/Timespeed.disabled = Globals.Tachyons.less(tspcost())
		%TopButtons/Timespeed/BuyMax.disabled = Globals.Tachyons.less(tspcost())
		%TopButtons/Timespeed.text = "Timespeed (%s TC) " % tspcost().to_string()
	%TopButtons/Timespeed.tooltip_text = "Purchased %s time%s" % \
	[Globals.int_to_string(TSpeedCount), "" if TSpeedCount == 1 else "s"]
	if Globals.EDHandler.DimsUnlocked > 0:
		%TopButtons/Timespeed.tooltip_text += " + %s Free upgrade%s" % [
			Globals.int_to_string(Globals.EDHandler.FreeTSpeed),
			"" if Globals.EDHandler.FreeTSpeed == 1 else "s"
		]
	%TopButtons/BuyMode.text = \
	"Buy until %s" % Globals.int_to_string(buylim) if %TopButtons/BuyMode.button_pressed else "Buy singles"
	if Globals.display == Globals.DisplayMode.Dozenal:
		%Progress.tooltip_text = "Pergrossage to "
	else:
		%Progress.tooltip_text = "Percentage to "
	if Globals.Challenge <= 15:
		%Progress.value = Globals.Tachyons.log2()
		%Progress.max_value = logfinity
		%Progress.tooltip_text += "Eternity"
	else:
		%Progress.value = Globals.Tachyons.log2()
		%Progress.max_value = Globals.ECTargets[Globals.Challenge - 16].log2()
		%Progress.tooltip_text += "Challenge goal"
	%Progress/Label.text = Globals.percent_to_string(%Progress.value / %Progress.max_value, 1)
	%Progress/Label.add_theme_color_override("font_color", get_theme_color("font_color", "ProgressBar"))
	rewindNode.visible = (Globals.TDilation >= 5) or (Globals.progress >= Globals.Progression.Galaxy)
	
	var buy10mult = 2
	if Globals.Challenge == 4: buy10mult = 1.0 + 0.2 * Globals.TDilation
	elif Globals.EUHandler.is_bought(5): buy10mult = 2.2222222
	
	%Important.text = \
	"[center]You have [font_size=20]" + Globals.Tachyons.to_string() + \
	"[/font_size] Tachyons.\n[font_size=10]You're gaining [/font_size]" + TCperS.to_string() + \
	"[font_size=10] Tachyons per second.[/font_size]\n[font_size=10]Timespeed strength: [/font_size]" + \
	TSpeedBoost.to_string() + "[font_size=10] | Total speed: [/font_size]" + \
	TSpeedBoost.power(TSpeedCount + Globals.EDHandler.FreeTSpeed).to_string() + \
	"[font_size=10]/sec\nBuy " + Globals.int_to_string(buylim) + " multiplier: [/font_size]" + \
	Globals.float_to_string(buy10mult)
	
	if rewindNode.visible:
		%Important.text += "[font_size=10] | Rewind multiplier: [/font_size]" + RewindMult.to_string()
	
	if Globals.Challenge == 2:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]" + \
		Globals.percent_to_string(C2Multiplier)
	if Globals.Challenge == 3:
		%Important.text += "\n \n[font_size=10]%s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(3), Globals.int_to_string(3)]
		%Important.text += "\n[font_size=10]%s and %s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(2), Globals.ordinal(1), Globals.float_to_string(0.03)]
	if Globals.Challenge == 9:
		%Important.text += "\n \n[font_size=10]Dimensions %s-%s: [/font_size]/" % [
			Globals.int_to_string(1), Globals.int_to_string(7)
		] + Globals.Tachyons.power(0.05).to_string()
	if Globals.Challenge == 14:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/" + \
		Globals.float_to_string(C14Divisor)
	if Globals.Challenge == 16:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/" + \
		Globals.float_to_string(C14Divisor) + ", " + Globals.percent_to_string(C2Multiplier)
	if %Prestiges/DiButton.material != null:
		%Prestiges/DiButton.material.\
		set_shader_parameter("disabled", %Prestiges/DiButton.disabled)
	
	if Globals.TDilation < 5 and Globals.Challenge != 13:
		rewindNode.disabled = true
		rewindNode.text = "Dimensional Rewind disabled (requires %s Time Dilation) " % \
		Globals.int_to_string(5)
	elif DimAmount[7].exponent == -INF and Globals.Challenge != 13:
		rewindNode.disabled = true
		rewindNode.text = "Dimensional Rewind disabled (no %s TD)" % \
		Globals.ordinal(8)
	elif rewindBoost(rewindNode.score).less(RewindMult):
		rewindNode.disabled = true
		rewindNode.text = "Dimensional Rewind disabled (×%s multiplier)" % \
		Globals.int_to_string(1)
	else:
		rewindNode.disabled = false
		if Globals.Challenge == 13:
			rewindNode.text = "Dimensional Rewind (×%s to all TDs)" % [
				rewindBoost(rewindNode.score).divide(RewindMult).to_string()
			]
		else:
			rewindNode.text = "Dimensional Rewind (×%s to %s TD)" % [
				rewindBoost(rewindNode.score).divide(RewindMult).to_string(), Globals.ordinal(8)
			]
		if Input.is_action_pressed("Rewind"):
			rewind(rewindNode.score)
	
	%Prestiges/GaButton.text = "Reset your Dimensions and\n" + \
	"Time Dilation to boost the power\nof Timespeed upgrades"
	var DilaBoost = 2
	if Globals.EUHandler.is_bought(10): DilaBoost = 2.5
	if Globals.OEUHandler.is_bought(5): DilaBoost = 3.0
	if Globals.ECCompleted(7): DilaBoost = 5.0
	if Globals.Challenge == 10:
		DilaBoost = 2.2 ** (1 - abs(C10Score()))
	if Globals.Challenge == 8: DilaBoost = 1
	if Globals.Challenge == 22: DilaBoost = 10
	pass
	DilaBoost = largenum.new(DilaBoost)
	if Globals.progress >= Globals.Progression.Boundlessness:
		DilaBoost.mult2self(Formulas.bounlesspower())
	
	if Globals.Challenge == 6 or Globals.Challenge == 16:
		if DimsUnlocked < 6:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % \
			Globals.ordinal(DimsUnlocked + 1) +\
			" and\ngain a ×%s multiplier to Dimension%s" % [
				DilaBoost.to_string(),
				(
					"s %s-%s" % [Globals.int_to_string(1),
					Globals.int_to_string(Globals.TDilation + 1)] \
					if Globals.TDilation != 0 \
					else " " + Globals.int_to_string(1)
				)
			]
		else:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions"
			if not DilaBoost.less(1.1):
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to %s" % [
					DilaBoost.to_string(),
					("all Dimensions" if Globals.TDilation >= 5 else "Dimensions 1-%d" % (Globals.TDilation + 1))
				]
	else:
		if Globals.TDilation == 4:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock Rewind"
			if not DilaBoost.less(1.1):
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					DilaBoost.to_string(),
					("s %s-%s" % [
						Globals.int_to_string(1),
						Globals.int_to_string(Globals.TDilation + 1)
					]if Globals.TDilation != 0 else " " + Globals.int_to_string(1))
				]
		elif Globals.TDilation < 0:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
		elif Globals.TDilation >= 5:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions"
			if not DilaBoost.less(1.1):
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to all Dimensions" % \
				DilaBoost.to_string()
		else:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
			if not DilaBoost.less(1.1):
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					DilaBoost.to_string(),
					("s %s-%s" % [
						Globals.int_to_string(1),
						Globals.int_to_string(Globals.TDilation + 1)
					]if Globals.TDilation != 0 else " " + Globals.int_to_string(1))
				]
	
	%Prestiges/DiButton.disabled = DimPurchase[DimsUnlocked - 1] < dilacost()
	%Prestiges/DiLabel.text = \
	"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % [
		Globals.int_to_string(Globals.TDilation),
		Globals.int_to_string(dilacost()),
		Globals.ordinal(DimsUnlocked)
	]
	
	%Prestiges/GaButton.disabled = DimPurchase[
		5 if Globals.Challenge in [6, 16] else 7
	] < galacost()
	%Prestiges/GaLabel.text = "[center]%sTachyon Galaxies (%s)\n%s[font_size=10]Requires: %s %s Tachyon Dimensions%s" % [
		("" if Globals.TGalaxies < DistantScaling else "Distant "),
		(
			"%s + %s" % [
				Globals.int_to_string(Globals.TGalaxies),
				Globals.int_to_string(Globals.DupHandler.dupGalaxies)
			]
			if Globals.DupHandler.dupGalaxies > 0 else
			"%s" % Globals.int_to_string(Globals.TGalaxies)
		),
		("[font_size=2] \n" if Globals.TGalaxies < DistantScaling else ""),
		Globals.int_to_string(galacost()),
		Globals.ordinal(
			6 if (Globals.Challenge == 6 or Globals.Challenge == 16) else 8),
		("" if Globals.TGalaxies < DistantScaling else 
		"\nEvery Galaxy is more expensive after %s Galaxies" %
		Globals.int_to_string(DistantScaling))
	]
	
	if Globals.Challenge == 8:
		if Globals.TDilation >= 5:
			%Prestiges/DiButton.disabled = true
			%Prestiges/DiButton.text = "Time Dilation capped\n(Challenge %s)" % Globals.int_to_string(8)
		%Prestiges/GaButton.disabled = true
		%Prestiges/GaButton.text = "Tachyon Galaxies disabled\n(Challenge %s)" % Globals.int_to_string(8)
	if Globals.Challenge == 2  or Globals.Challenge == 16:
		C2Multiplier += delta / 60
		C2Multiplier = min(C2Multiplier, 1)
	if Globals.Challenge == 14 or Globals.Challenge == 16:
		C14Divisor *= 1e9 ** delta
	if Globals.Challenge == 22:
		%Prestiges/GaButton.disabled = true
		%Prestiges/GaButton.text = "Tachyon Galaxies disabled\n(Eternity Challenge %s)" % \
		Globals.int_to_string(7)
	%Prestiges/Reset.visible = (Globals.Challenge in [14, 18, 19]) and \
	Globals.TDilation > -3
	
	if not Input.is_action_pressed("ToggleAB"):
		for i in range(8, 0, -1):
			if Input.is_action_pressed("BuyTD%d" % i) or BuyMax:
				if Input.is_action_pressed("BuyOne") and not BuyMax:
					buydim(i, 1)
				elif dims[i].get_node("Buy/Progress").value >= \
				dims[i].get_node("Buy/Progress").max_value:
					buydim(i, 0)
					if BuyMax:
						buydim(i, 1e9)
		if Input.is_action_pressed("BuyTSpeed") or BuyMax:
			if tspcost().less(Globals.Tachyons):
				buytspeed(not Input.is_action_pressed("BuyOne") or BuyMax)
	BuyMax = Input.is_action_pressed("BuyMax")
	
	for i in 8:
		dims[i+1].get_node("N&M/Name").text = "%s Tachyon Dimension" % Globals.ordinal(i+1)
	
	if Input.is_action_pressed("Dilate"):
		if not %Prestiges/DiButton.disabled:
			dilate()
	if Input.is_action_pressed("Galaxy"):
		if not %Prestiges/GaButton.disabled:
			galaxy()
	if Input.is_action_pressed("BBang"):
		if $ETERNITY.visible:
			eternity()
	
	if Globals.Challenge == 10:
		if %Prestiges/DiButton.material == null:
			%Prestiges/DiButton.material = rewindNode.material.duplicate()
		%Prestiges/DiButton.material.set_shader_parameter(
			"pixelsize", 1./250.
		)
		%Prestiges/DiButton/Accuracy.visible = true
		%Prestiges/DiButton/Accuracy.position.x = (
			(C10Score() * 230) + 240
		) / 2
	else:
		%Prestiges/DiButton/Accuracy.visible = false
	
	for i in range(min(DimsUnlocked, len(dims) - 1), 0, -1):
		var mult := largenum.new(1)
		
		mult.mult2self(largenum.new(buy10mult).power(DimPurchase[i-1] / buylim))
		if Globals.Challenge == 10:
			mult.mult2self(largenum.new(2.2).power(max(      C10Power    - i + 1, 0)))
		else:
			mult.mult2self(        DilaBoost.power(max(Globals.TDilation - i + 1, 0)))
		
		if Globals.Challenge != 13:
			if Globals.EUHandler.is_bought(1): mult.mult2self(Formulas.eternity_11())
			if Globals.EUHandler.is_bought(2):
				if i == 1 or i == 8: mult.mult2self(Formulas.eternity_23())
			if Globals.EUHandler.is_bought(3):
				if i == 2 or i == 7: mult.mult2self(Formulas.eternity_23())
			if Globals.EUHandler.is_bought(7):
				if i == 3 or i == 6: mult.mult2self(Formulas.eternity_23())
			if Globals.EUHandler.is_bought(6):
				if i == 4 or i == 5: mult.mult2self(Formulas.eternity_23())
			if Globals.EUHandler.is_bought(9): mult.mult2self(Formulas.achievement_mult())
			if Globals.EUHandler.is_bought(11): mult.mult2self(Globals.EternityPts.add(1))
		
		if i == 8 or Globals.Challenge == 13:
			mult.mult2self(RewindMult)
		elif "Tach1" in Globals.Studies.purchased:
			mult.mult2self(Formulas.study_tach1())
		
		if Globals.Challenge == 2 or Globals.Challenge == 16: mult.mult2self(C2Multiplier)
		if Globals.Challenge == 3:
			if i == 3: mult.mult2self(3)
			if i <= 2: mult.mult2self(0.03)
		if Globals.Challenge == 9 and i != 8:
			mult.div2self(Globals.Tachyons.power(0.05))
		if Globals.Challenge == 14 or Globals.Challenge == 16: mult.div2self(C14Divisor)
		
		if Globals.Challenge != 13:
			if Globals.Achievemer.is_unlocked(2, 5): mult.mult2self(1.1)
			if Globals.Achievemer.is_unlocked(2, 7) and i == 1: mult.mult2self(1.5)
			if Globals.Achievemer.is_unlocked(3, 4) and i != 8: mult.mult2self(1.5)
			if Globals.Achievemer.is_unlocked(4, 8): mult.mult2self(1.2)
			
			if Globals.OEUHandler.is_bought(1):
				mult.mult2self(Formulas.overcome_1())
			if Globals.Achievemer.is_unlocked(5, 6):
				mult.mult2self(Formulas.achievement_56())
			
			if Globals.Achievemer.is_unlocked(6, 2) and i <= 4:
				mult.mult2self(3)
		
		if not Globals.Achievemer.is_unlocked(3, 1) and mult.log10() >= 40:
			Globals.Achievemer.set_unlocked(3, 1)
		
		if Globals.Challenge == 18 and i != latest_purchased:
			mult.pow2self(0.2)
		
		dims[i].get_node("N&M/Multiplier").text = "×%s" % mult.to_string()
		mult.mult2self(TSpeedBoost.power(TSpeedCount + Globals.EDHandler.FreeTSpeed))
		
		if i != 8:
			if DimAmount[i].exponent == -INF:	dims[i].get_node("A&G/Growth").hide()
			else:								dims[i].get_node("A&G/Growth").show()
			if DimAmount[i-1].exponent == -INF:
				dims[i+1].modulate.a = 0.5
			else:
				dims[i+1].modulate.a = 1.0
		if i == 1:
			TCperS = DimAmount[i-1].multiply(mult)
			Globals.Tachyons   .add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
			Globals.TachTotalBL.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
			Globals.TachTotal  .add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
		else:
			if DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).less(10):
				dims[i-1].get_node("A&G/Growth").text = "(+%s/s)" % \
					Globals.percent_to_string(DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_float())
			else:
				dims[i-1].get_node("A&G/Growth").text = "(×%s/s)" % \
					DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_string()
			DimAmount[i-2].add2self(DimAmount[i-1].multiply(mult.multiply(delta)))

func dilacost():
	var Cost := 20
	
	if (Globals.Challenge == 6 or Globals.Challenge == 16) and DimsUnlocked == 6:
		Cost = 30 + (Globals.TDilation - 3) * 10
	elif DimsUnlocked == 8:
		Cost = 5 + (Globals.TDilation - 3) * 15
	
	if (Globals.Challenge == 5 or Globals.Challenge == 16):
		Cost = Cost * 3 / 2
	if Globals.Challenge == 19:
		Cost += Globals.TGalaxies * 15
	if Globals.EUHandler.is_bought(4):
		Cost -= 5
	if Globals.ECCompleted(4):
		Cost -= 5
	
	return Cost

func galacost():
	var Cost = 80 + 60 * Globals.TGalaxies
	
	if (Globals.Challenge == 6 or Globals.Challenge == 16):
		Cost = 60 + 40 * Globals.TGalaxies
	
	if "3×1" in Globals.Studies.purchased:
		Cost -= 5 * Globals.TGalaxies
	
	if (Globals.Challenge == 5 or Globals.Challenge == 16):
		Cost = Cost * 3 / 2
	if Globals.Challenge == 19:
		Cost += Globals.TDilation * 5
	if Globals.EUHandler.is_bought(4):
		Cost -= 10
	if Globals.TGalaxies > DistantScaling:
		var the = (Globals.TGalaxies - DistantScaling)
		Cost += the * (the + 1)
	if Globals.TGalaxies > 600:
		var the = (Globals.TGalaxies - 600)
		Cost *= 1.002 ** the
	
	return Cost

signal eternitied()
