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
var DimCost : Array[largenum] = [
	largenum.ten_to_the(1),largenum.ten_to_the( 2),largenum.ten_to_the( 4),largenum.ten_to_the( 6),
	largenum.ten_to_the(9),largenum.ten_to_the(13),largenum.ten_to_the(18),largenum.ten_to_the(24)
]
var DimCostMult : Array[largenum] :
	get:
		var base : Array[largenum] = [
			largenum.ten_to_the(3),largenum.ten_to_the( 4),largenum.ten_to_the( 5),largenum.ten_to_the( 6),
			largenum.ten_to_the(8),largenum.ten_to_the(10),largenum.ten_to_the(12),largenum.ten_to_the(15)
		]
		if Globals.Challenge == 1 or Globals.Challenge == 16:
			base = [
				largenum.ten_to_the( 4),largenum.ten_to_the( 6),largenum.ten_to_the( 8),largenum.ten_to_the(10),
				largenum.ten_to_the(13),largenum.ten_to_the(15),largenum.ten_to_the(17),largenum.ten_to_the(20)
			]
		var costscaling = 10 - Globals.OEUHandler.TDmScBought
		for i in 8:
			if DimPurchase[i] / buylim >= CostScaleStart[i]:
				base[i].mult2self(largenum.new(costscaling).power(
					DimPurchase[i] / buylim - CostScaleStart[i]
				))
		return base
const CostScaleStart := [103, 77, 61, 51, 38, 30, 25, 19]
const TSpeedScaleStart := 305

var TSpeedBoost := largenum.new(1.13)
var TSpeedCost := largenum.new(1000)
var TSpeedCostIncrease : largenum :
	get:
		var base = largenum.new(10)
		var costscaling = 10 - Globals.OEUHandler.TSpScBought
		if Globals.Challenge == 5 or Globals.Challenge == 16: base.mult2self(1.5)
		if TSpeedCount >= TSpeedScaleStart:
			base.mult2self(largenum.new(costscaling).power(TSpeedCount - TSpeedScaleStart))
		return base
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
		var TC = TSpeedCost
		reset(0)
		RewindMult = RM
		TSpeedCount = TS
		TSpeedCost = TC
	else:
		for i in 7:
			DimAmount[i].pow2self(1 - score)
			if DimAmount[i].less(DimPurchase[i]):
				DimAmount[i] = largenum.new(DimPurchase[i])

func rewindBoost(score := 1.0) -> largenum:
	var RBoost = largenum.new(DimAmount[0].log10()).pow2self(1.5).div2self(10)
	if Globals.Challenge == 8:
		RBoost = DimAmount[0].power(0.1)
	if Globals.OEUHandler.is_bought(6):
		RBoost = DimAmount[0].power(0.05)
	if Globals.Achievemer.is_unlocked(5, 4): RBoost.pow2self(1.2)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(2)
	
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.div2self(RewindMult)
	RBoost.pow2self(score)
	if Globals.Achievemer.is_unlocked(2, 4): RBoost.mult2self(RewindMult)
	
	return RBoost

func buydim(which, bulkoverride := 0):
	while true:
		if which > DimsUnlocked:
			return
		var bulk :int= 1
		if (
			(%TopButtons/BuyMode.button_pressed
			and not Input.is_action_pressed("BuyOne"))
			or bulkoverride != 0
		):
			if Globals.Tachyons.divide(DimCost[which-1]).to_float() >= buylim:
				bulk = buylim - DimPurchase[which-1] % buylim
			else:
				bulk = min(
					(Globals.Tachyons.divide(DimCost[which-1])).to_float(),
					buylim - DimPurchase[which-1] % buylim
				)
		
		if bulk < 1:
			return
		
		if bulkoverride > 0:
			if min(bulkoverride, buylim - DimPurchase[which-1] % buylim) > bulk:
				return
			bulk = min(bulk, bulkoverride)
		
		Globals.Tachyons.add2self(DimCost[which-1].neg().mult2self(bulk))
		DimPurchase[which-1] += bulk
		DimAmount[which-1].add2self(bulk)
		if DimPurchase[which-1] % buylim == 0:
			DimCost[which-1].mult2self(DimCostMult[which-1])
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
	while TSpeedCost.less(Globals.Tachyons):
		Globals.Tachyons.add2self(TSpeedCost.neg())
		if Globals.Tachyons.sign < 0:
			Globals.Tachyons.add2self(TSpeedCost)
			return
		TSpeedCost.mult2self(TSpeedCostIncrease)
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
	if  Globals.progress < Globals.Progression.Dilation:
		Globals.progress = Globals.Progression.Dilation

func galaxy():
	if Globals.Challenge == 22: return
	reset(1)
	Globals.TGalaxies += 1
	updateTSpeed()
	if  Globals.progress < Globals.Progression.Galaxy:
		Globals.progress = Globals.Progression.Galaxy

func eternity():
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
	
	var epgain = epgained()
	
	Globals.EternityPts.add2self(epgain)
	Globals.Eternities .add2self(1)
	
	if Globals.progress < Globals.Progression.Eternity:
		Globals.progress = Globals.Progression.Eternity
	
	if Globals.fastestEtern.time > Globals.eternTime \
	or Globals.fastestEtern.time < 0:
		Globals.fastestEtern.time		= Globals.eternTime
		Globals.fastestEtern.epgain		= epgain
		Globals.fastestEtern.eternities = largenum.new(1)
	
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
	if not Globals.Achievemer.is_unlocked(3, 7) and Globals.TGalaxies == 1:
		Globals.Achievemer.set_unlocked(3, 7)
	if not Globals.Achievemer.is_unlocked(6, 2) and Globals.TGalaxies == 0 and \
	Globals.TDilation <= 0:
		Globals.Achievemer.set_unlocked(6, 2)
	if not Globals.Achievemer.is_unlocked(6, 6) and Globals.TGalaxies == 0 and \
	Globals.TDilation <= -3:
		Globals.Achievemer.set_unlocked(6, 6)
	
	Globals.last10etern.insert(0, Globals.EternityData.new(
		Globals.eternTime, epgain, 1
	))
	if Globals.last10etern.size() > 10:
		Globals.last10etern.resize(10)
	
	await get_tree().process_frame
	reset(2)
	Globals.animation("bang")

func epgained():
	var epgain = largenum.new(1)
	if Globals.Challenge == 15 or Globals.progress >= Globals.Progression.Overcome:
		epgain = largenum.new(5).power((topTachyonsInEternity.log2() / 1024) - 1)
		if Globals.OEUHandler.is_bought(4):
			epgain = largenum.new(5).power((topTachyonsInEternity.log2() / 900) - 1)
	
	epgain.mult2self(largenum.new(2).power(Globals.EUHandler.EPMultBought))
	
	if epgain.to_float() < 1e10:
		epgain = largenum.new(floor(epgain.to_float() + 0.1))
	
	return epgain

func reset(level := 0, challengeReset := true):
	if level >= 2 and challengeReset: Globals.Challenge = 0
	if Globals.Challenge == 2  or Globals.Challenge == 16: C2Multiplier = 1.0
	if Globals.Challenge == 14 or Globals.Challenge == 16:  C14Divisor = 1.0
	if   Globals.Achievemer.is_unlocked(4,2):
		Globals.Tachyons = largenum.new(5e5)
	elif Globals.Achievemer.is_unlocked(3,6):
		Globals.Tachyons = largenum.new(5000)
	elif Globals.Achievemer.is_unlocked(2,8):
		Globals.Tachyons = largenum.ten_to_the(2)
	else:
		Globals.Tachyons = largenum.ten_to_the(1)
	DimPurchase = [0,0,0,0,0,0,0,0]
	DimCost = [
		largenum.ten_to_the( 1),largenum.ten_to_the( 2),
		largenum.ten_to_the( 4),largenum.ten_to_the( 6),
		largenum.ten_to_the( 9),largenum.ten_to_the(13),
		largenum.ten_to_the(18),largenum.ten_to_the(24)
	]
	for i in DimAmount:
		i.exponent = -INF # set to zero
		i.fix_mantissa()
	TSpeedCost = largenum.ten_to_the(3)
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

func _process(delta):
	
	var logfinity = 2048 if Globals.Challenge == 15 else 1024
	
	if canBigBang and Input.is_action_pressed("BBang"):
		eternity()
	
	if topTachyonsInEternity.less(Globals.Tachyons):
		topTachyonsInEternity = largenum.new(Globals.Tachyons)
	
	if Globals.progress < GL.Progression.Overcome or \
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
		custom_minimum_size.y = $VSplitContainer.size.y
		$VSplitContainer.visible = true
		$ETERNITY.visible = false
	
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
		var buyable = (Globals.Tachyons.divide(DimCost[k-1])).to_float()
		if abs(buyable) > buylim:
			buyable = buylim
		buyable = int(buyable)
		i.get_node("Buy/Progress").value = int(buyable)
		i.get_node("Buy/Progress").max_value = buylim - DimPurchase[k-1] % buylim
		i.get_node("Buy").disabled = not DimCost[k-1].less(Globals.Tachyons)
		if k < 8:
			if DimAmount[k].exponent == -INF:
				i.get_node("A&G/Amount").text = Globals.int_to_string(DimPurchase[k-1])
			else:
				i.get_node("A&G/Amount").text = DimAmount[k-1].to_string()
		else:
			i.get_node("A&G/Amount").text = Globals.int_to_string(DimPurchase[k-1])
		i.get_node("Buy").text = "Buy %s\nCost: %s TC" % [
			Globals.int_to_string(min(buyable, buylim - DimPurchase[k-1] % buylim)),
			DimCost[k-1].multiply(min(max(buyable, 1), buylim - DimPurchase[k-1] % buylim)).to_string()
		]
	if Globals.Challenge == 20:
		%TopButtons/Timespeed.disabled = true
		%TopButtons/Timespeed/BuyMax.disabled = true
		%TopButtons/Timespeed.text = "Timespeed disabled (EC5)"
	else:
		%TopButtons/Timespeed.disabled = Globals.Tachyons.less(TSpeedCost)
		%TopButtons/Timespeed/BuyMax.disabled = Globals.Tachyons.less(TSpeedCost)
		%TopButtons/Timespeed.text = "Timespeed (%s TC) " % TSpeedCost.to_string()
	%TopButtons/Timespeed.tooltip_text = "Purchased %s time%s" % \
	[Globals.int_to_string(TSpeedCount), "" if TSpeedCount == 1 else "s"]
	if Globals.EDHandler.DimsUnlocked > 0:
		%TopButtons/Timespeed.tooltip_text += " + %s Free upgrade%s" % [
			Globals.int_to_string(Globals.EDHandler.FreeTSpeed),
			"" if Globals.EDHandler.FreeTSpeed == 1 else "s"
		]
	%TopButtons/BuyMode.text = \
	"Buy until %s" % Globals.int_to_string(buylim) if %TopButtons/BuyMode.button_pressed else "Buy singles"
	%Progress.value = Globals.Tachyons.log2()
	%Progress.max_value = logfinity
	if Globals.display == Globals.DisplayMode.Dozenal:
		%Progress.tooltip_text = "Pergrossage to Eternity"
	else:
		%Progress.tooltip_text = "Percentage to Eternity"
	%Progress/Label.text = Globals.percent_to_string(%Progress.value / %Progress.max_value, 1)
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
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/ " + \
		Globals.Tachyons.power(0.05).to_string()
	if Globals.Challenge == 14:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/ " + \
		Globals.float_to_string(C14Divisor)
	if Globals.Challenge == 16:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/ " + \
		Globals.float_to_string(C14Divisor) + ", " + Globals.percent_to_string(C2Multiplier)
	
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
	
	if Globals.Challenge == 6 or Globals.Challenge == 16:
		if DimsUnlocked < 6:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % \
			Globals.ordinal(DimsUnlocked + 1) +\
			" and\ngain a ×%s multiplier to Dimension%s" % [
				Globals.float_to_string(DilaBoost,1),
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
			if DilaBoost > 1.1:
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to %s" % [
					Globals.float_to_string(DilaBoost, 1),
					("all Dimensions" if Globals.TDilation >= 5 else "Dimensions 1-%d" % (Globals.TDilation + 1))
				]
	else:
		if Globals.TDilation == 4:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock Rewind"
			if DilaBoost > 1.1:
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					Globals.float_to_string(DilaBoost,1),
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
			if DilaBoost > 1.1:
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to all Dimensions" % \
				Globals.float_to_string(DilaBoost, 1)
		else:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
			if DilaBoost > 1.1:
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					Globals.float_to_string(DilaBoost,1),
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
	if Globals.DupHandler.dupGalaxies > 0:
		%Prestiges/GaLabel.text = "[center]Tachyon Galaxies (%s + %s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % [
			Globals.int_to_string(Globals.TGalaxies), Globals.int_to_string(Globals.DupHandler.dupGalaxies),
			Globals.int_to_string(galacost()),
			Globals.ordinal(6 if (Globals.Challenge == 6 or Globals.Challenge == 16) else 8)
		]
	else:
		%Prestiges/GaLabel.text = "[center]Tachyon Galaxies (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % [
			Globals.int_to_string(Globals.TGalaxies),
			Globals.int_to_string(galacost()),
			Globals.ordinal(6 if (Globals.Challenge == 6 or Globals.Challenge == 16) else 8)
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
	%Prestiges/Reset.visible = (Globals.Challenge in [18, 19])
	
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
			if TSpeedCost.less(Globals.Tachyons):
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
	
	for i in range(1, min(DimsUnlocked+1, len(dims))):
		var mult := largenum.new(1)
		
		mult.mult2self(largenum.new(buy10mult).power(DimPurchase[i-1] / buylim))
		if Globals.Challenge == 10:
			mult.mult2self(largenum.new(   2.2   ).power(max(      C10Power    - i + 1, 0)))
		else:
			mult.mult2self(largenum.new(DilaBoost).power(max(Globals.TDilation - i + 1, 0)))
		
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
		
		if Globals.Challenge == 2 or Globals.Challenge == 16: mult.mult2self(C2Multiplier)
		if Globals.Challenge == 3:
			if i == 3: mult.mult2self(3)
			if i <= 2: mult.mult2self(0.03)
		if Globals.Challenge ==  9: mult.div2self(Globals.Tachyons.power(0.05))
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
		if i == 1:
			TCperS = DimAmount[i-1].multiply(mult)
			Globals.Tachyons .add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
			Globals.TachTotal.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
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
	if (Globals.Challenge == 5 or Globals.Challenge == 16):
		Cost = Cost * 3 / 2
	if Globals.Challenge == 19:
		Cost += Globals.TDilation * 5
	if Globals.EUHandler.is_bought(4):
		Cost -= 10
	
	return Cost

signal eternitied()
