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
	largenum.new(10   ),largenum.new(100   ),largenum.new(10**4 ),largenum.new(10**6),
	largenum.new(10**9),largenum.new(10**13),largenum.new(10**18),largenum.new(10).power(24)
]
var DimCostMult : Array[largenum] :
	get:
		if Globals.Challenge == 1:
			return [
			largenum.new(10**4 ),largenum.new(10**6 ),largenum.new(10**8 ),largenum.new(10**10),
			largenum.new(10**13),largenum.new(10).power(15),
			largenum.new(10).power(17),largenum.new(10).power(20)
		]
		else:
			return [
			largenum.new(1000 ),largenum.new(10**4 ),largenum.new(10**5 ),largenum.new(10**6),
			largenum.new(10**8),largenum.new(10**10),largenum.new(10**12),largenum.new(10**15)
		]

var TSpeedBoost := largenum.new(1.15)
var TSpeedCost := largenum.new(1000)
var TSpeedCount := 0

var DimsUnlocked := 4
var TCperS := largenum.new(0)
var BuyMax : bool

var C2Multiplier := 1.0
var C10Power := 0.0
func C10Score():
	return sin(Time.get_ticks_msec() / 1000.0)

var RewindMult := largenum.new(1)

var buylim : int :
	get:
		if Globals.Challenge == 5:  return 15
		else: 						return 10

func updateTSpeed():
	var GalaxyBoost = 0.01
	if Globals.EUHandler.is_bought(8): GalaxyBoost *= 2
	if Globals.Challenge == 12:
		TSpeedBoost = largenum.new(1.10 + GalaxyBoost * Globals.TGalaxies)
	else:
		TSpeedBoost = largenum.new(1.13 + GalaxyBoost * Globals.TGalaxies)

func rewind(score:float):
	RewindMult = rewindBoost().power(score)
	if Globals.Challenge == 8:
		if Globals.Achievemer.is_unlocked(2,1):
			Globals.Tachyons = largenum.new(100)
		else:
			Globals.Tachyons = largenum.new(10)
		DimPurchase = [0,0,0,0,0,0,0,0]
		DimCost = [
			largenum.new(10   ),largenum.new(100   ),largenum.new(10**4 ),largenum.new(10**6),
			largenum.new(10**9),largenum.new(10**13),largenum.new(10**18),largenum.new(10).power(24)
		]
		DimAmount = [
			largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
			largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
		]
	else:
		for i in 7:
			DimAmount[i].pow2self(1 - score)

func rewindBoost() -> largenum:
	if Globals.Challenge == 8:
		return DimAmount[0].power(0.075)
	return largenum.new(DimAmount[0].log10()).power(1.5).divide(10)

func buydim(which, bulkoverride := 0):
	if which > DimsUnlocked: return
	var bulk :int= 1
	if (
		(%TopButtons/BuyMode.button_pressed
		and not Input.is_action_pressed("BuyOne"))
		or bulkoverride != 0
	):
		if is_inf(Globals.Tachyons.divide(DimCost[which-1]).to_float()):
			bulk = buylim - DimPurchase[which-1] % buylim
		else:
			bulk = min((Globals.Tachyons.divide(DimCost[which-1])).to_float(), buylim - DimPurchase[which-1] % buylim)
	if bulkoverride > 0:
		if bulk < (bulkoverride - 1) % buylim + 1: return
		bulk = (bulkoverride - 1) % buylim + 1
	
	if Globals.Challenge == 2: C2Multiplier = 0.0
	if Globals.Challenge == 7: for i in which - 1: DimAmount[i] = largenum.new(DimPurchase[i])
	
	if bulk < 1:
		return
	Globals.Tachyons.add2self(DimCost[which-1].neg().multiply(largenum.new(bulk)))
	DimPurchase[which-1] += bulk
	DimAmount[which-1].add2self(largenum.new(bulk))
	if DimPurchase[which-1] % buylim == 0:
		DimCost[which-1].mult2self(DimCostMult[which-1])
	
	if bulkoverride > 10:
		buydim(which, bulkoverride - 10)

func buytspeed(maxm:bool):
	while TSpeedCost.less(Globals.Tachyons):
		Globals.Tachyons.add2self(TSpeedCost.neg())
		TSpeedCost.mult2self(10)
		TSpeedCount += 1
		if Globals.Challenge == 2: C2Multiplier = 0.0
		if not maxm or Input.is_action_pressed("BuyOne"): break

func dilate():
	reset(0)
	Globals.TDilation += 1
	if Globals.Challenge == 10:
		C10Power += 1 - abs(C10Score())
	if  Globals.progress < Globals.Progression.Dilation:
		Globals.progress = Globals.Progression.Dilation

func galaxy():
	reset(1)
	Globals.TGalaxies += 1
	updateTSpeed()
	if  Globals.progress < Globals.Progression.Galaxy:
		Globals.progress = Globals.Progression.Galaxy

func eternity():
	if Globals.Challenge != 0:
		Globals.CompletedChallenges |= 1 << (Globals.Challenge - 1)
	Globals.EternityPts.add2self(1)
	Globals.Eternities .add2self(1)
	reset(2)
	if Globals.progress < Globals.Progression.Eternity:
		Globals.progress = Globals.Progression.Eternity
	Globals.animation("bang")

func reset(level := 0, challengeReset := true):
	if level >= 2 and challengeReset: Globals.Challenge = 0
	if Globals.Challenge == 2: C2Multiplier = 1.0
	if Globals.Achievemer.is_unlocked(2,8):
		Globals.Tachyons = largenum.new(100)
	else:
		Globals.Tachyons = largenum.new(10)
	DimPurchase = [0,0,0,0,0,0,0,0]
	DimCost = [
		largenum.new(10   ),largenum.new(100   ),largenum.new(10**4 ),largenum.new(10**6),
		largenum.new(10**9),largenum.new(10**13),largenum.new(10**18),largenum.new(10).power(24)
	]
	DimAmount = [
		largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
		largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
	]
	TSpeedCost = largenum.new(1000)
	TSpeedCount = 0
	RewindMult = largenum.new(1)
	if level >= 1:
		Globals.TDilation = 0
		if Globals.Challenge == 11: Globals.TDilation = -3
		if Globals.Challenge == 10: C10Power = 0
	if level >= 2:
		Globals.TGalaxies = 0
		if Globals.Challenge == 10:
			%Prestiges/DiButton.material = rewindNode.material.duplicate()
			%Prestiges/DiButton.material.set_shader_parameter("pixelsize", 1./250.)
		else:
			%Prestiges/DiButton.material = null
	updateTSpeed()

func _process(delta):
	$ScrollContainer.visible = (Globals.Tachyons.exponent <  1024)
	$ETERNITY.visible        = (Globals.Tachyons.exponent >= 1024)
	if Globals.Challenge == 2:
		C2Multiplier += delta / 60
		C2Multiplier = min(C2Multiplier, 1)
	
	if Globals.Tachyons.exponent >= 1024:
		Globals.Tachyons.exponent = 1024
		Globals.Tachyons.mantissa = (1 << 62)
		if Input.is_action_pressed("BBang"):
			eternity()
		return
	
	if Globals.Challenge == 6:
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
		i.get_node("Buy/Progress").value = int(min((Globals.Tachyons.divide(DimCost[k-1])).to_float(), buylim))
		i.get_node("Buy/Progress").max_value = buylim - DimPurchase[k-1] % buylim
		i.get_node("Buy").disabled = Globals.Tachyons.less(DimCost[k-1])
		i.get_node("A&G/Amount").text = DimAmount[k-1].to_string()
		i.get_node("Buy").text = "Buy %s\nCost: %s TC" % [
			Globals.int_to_string(min(Globals.Tachyons.divide(DimCost[k-1]).to_float(), buylim - DimPurchase[k-1] % buylim)),
			DimCost[k-1].multiply(min(max(int((Globals.Tachyons.divide(DimCost[k-1])).to_float()), 1), buylim - DimPurchase[k-1] % buylim)).to_string()
		]
	%TopButtons/Timespeed.disabled = Globals.Tachyons.less(TSpeedCost)
	%TopButtons/Timespeed/BuyMax.disabled = Globals.Tachyons.less(TSpeedCost)
	%TopButtons/Timespeed.text = "Timespeed (%s TC)" % TSpeedCost.to_string()
	%TopButtons/Timespeed.tooltip_text = "Purchased %s time%s" % \
	[Globals.int_to_string(TSpeedCount), "" if TSpeedCount == 1 else "s"]
	%TopButtons/BuyMode.text = \
	"Buy until %s" % Globals.int_to_string(buylim) if %TopButtons/BuyMode.button_pressed else "Buy singles"
	%Progress.value = Globals.Tachyons.log2()
	if Globals.display == Globals.DisplayMode.Dozenal:
		%Progress.tooltip_text = "Pergrossage to Eternity"
	else:
		%Progress.tooltip_text = "Percentage to Eternity"
	%Progress/Label.text = Globals.percent_to_string(%Progress.value / %Progress.max_value, 1)
	rewindNode.visible = (Globals.TDilation >= 5) and (Globals.Challenge != 6)
	
	var buy10mult = 2
	if Globals.Challenge == 4: buy10mult = 1.0 + 0.2 * Globals.TDilation
	elif Globals.EUHandler.is_bought(5): buy10mult = 2.2222222
	
	%Important.text = \
	"[center]You have [font_size=20]" + Globals.Tachyons.to_string() + \
	"[/font_size] Tachyons.\n[font_size=10]You're gaining [/font_size]" + TCperS.to_string() + \
	"[font_size=10] Tachyons per second.[/font_size]\n[font_size=10]Timespeed strength: [/font_size]" + \
	TSpeedBoost.to_string() + "[font_size=10]. Total speed: [/font_size]" + \
	TSpeedBoost.power(TSpeedCount).to_string() + "[font_size=10]/sec\nBuy " + \
	Globals.int_to_string(buylim) + " multiplier: [/font_size]" + \
	Globals.float_to_string(buy10mult)
	
	if Globals.Challenge == 2:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]" + \
		Globals.percent_to_string(C2Multiplier)
	if Globals.Challenge == 3:
		%Important.text += "\n \n[font_size=10]%s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(3), Globals.int_to_string(3)]
		%Important.text += "\n[font_size=10]%s and %s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(2), Globals.ordinal(1), Globals.float_to_string(0.03)]
	
	if DimAmount[7].exponent == -INF:
		rewindNode.disabled = true
		rewindNode.text = "Dimensional Rewind disabled (no %s TD)" % \
		Globals.ordinal(8)
	elif rewindBoost().power(rewindNode.score).divide(RewindMult).less(1):
		rewindNode.disabled = true
		rewindNode.text = "Dimensional Rewind disabled (×%s multiplier)" % \
		Globals.int_to_string(1)
	else:
		rewindNode.disabled = false
		rewindNode.text = "Dimensional Rewind (×%s to %s TD)" % \
		[rewindBoost().power(rewindNode.score).divide(RewindMult).to_string(), Globals.ordinal(8)]
		if Input.is_action_pressed("Rewind"):
			rewind(rewindNode.score)
	
	%Prestiges/GaButton.text = "Reset your Dimensions and\n" + \
	"Time Dilation to boost the power\nof Timespeed upgrades"
	var DilaBoost = 2
	if Globals.EUHandler.is_bought(10): DilaBoost = 2.5
	if Globals.Challenge == 10:
		DilaBoost *= 1.1
		DilaBoost **= 1 - abs(C10Score())
	if Globals.Challenge == 8: DilaBoost = 1
	if Globals.Challenge == 6:
		if DimsUnlocked < 6:
			var Cost := 20
			if Globals.EUHandler.is_bought(4):
				Cost -= 5
			%Prestiges/DiButton.disabled = DimPurchase[DimsUnlocked - 1] < Cost
			%Prestiges/DiLabel.text = \
			"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % \
			[Globals.int_to_string(Globals.TDilation), Globals.int_to_string(Cost), Globals.ordinal(DimsUnlocked)]
			if Globals.TDilation < 0:
				%Prestiges/DiButton.text = \
				"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
			else:
				%Prestiges/DiButton.text = \
				"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
				if DilaBoost > 1.1:
					%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
					[Globals.float_to_string(DilaBoost,1), ("s %s-%s" % [Globals.int_to_string(1), Globals.int_to_string(Globals.TDilation + 1)] if Globals.TDilation != 0 else " " + Globals.int_to_string(1))]
		else:
			var Cost = 30 + (Globals.TDilation - 3) * 10
			if Globals.EUHandler.is_bought(4):
				Cost -= 5
			%Prestiges/DiButton.disabled = DimPurchase[5] < Cost
			%Prestiges/DiLabel.text = \
			"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % \
			[Globals.int_to_string(Globals.TDilation), Globals.int_to_string(Cost), Globals.ordinal(6)]
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\ngain a ×%s multiplier to %s" % [
				Globals.float_to_string(DilaBoost, 1),
				("all Dimensions" if Globals.TDilation >= 5 else "Dimensions 1-%d" % (Globals.TDilation + 1))
			]
		
		var GalCost = 60 + 40 * Globals.TGalaxies
		if Globals.EUHandler.is_bought(4):
			GalCost -= 10
		%Prestiges/GaButton.disabled = DimPurchase[5] < GalCost
		%Prestiges/GaLabel.text = "[center]Tachyon Galaxies (%s)\n[font_size=2] \n\
		[font_size=10]Requires: %s %s Tachyon Dimensions" % \
		[Globals.int_to_string(Globals.TGalaxies), Globals.int_to_string(GalCost), Globals.ordinal(6)]
	else:
		if DimsUnlocked < 8:
			var Cost := 20
			if Globals.Challenge == 5:
				Cost = Cost * 3 / 2
			if Globals.EUHandler.is_bought(4):
				Cost -= 5
			%Prestiges/DiButton.disabled = DimPurchase[DimsUnlocked - 1] < Cost
			%Prestiges/DiLabel.text = \
			"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % \
			[Globals.int_to_string(Globals.TDilation), Globals.int_to_string(Cost), Globals.ordinal(DimsUnlocked)]
			if Globals.TDilation < 0:
				%Prestiges/DiButton.text = \
				"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(DimsUnlocked + 1)
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
		else:
			var Cost = 5 + (Globals.TDilation - 3) * 15
			if Globals.Challenge == 5:
				Cost = Cost * 3 / 2
			if Globals.EUHandler.is_bought(4):
				Cost -= 5
			%Prestiges/DiButton.disabled = DimPurchase[7] < Cost
			%Prestiges/DiLabel.text = \
			"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % \
			[Globals.int_to_string(Globals.TDilation), Globals.int_to_string(Cost), Globals.ordinal(8)]
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
			else:
				%Prestiges/DiButton.text = \
				"Reset your Dimensions to\ngain a ×%s multiplier to %s" % [
					Globals.float_to_string(DilaBoost,1),
					("all Dimensions" if Globals.TDilation >= 7 else "Dimensions %s-%s" % [Globals.int_to_string(1), Globals.int_to_string(Globals.TDilation + 1)])
				]
		
		var GalCost = 80 + 60 * Globals.TGalaxies
		if Globals.Challenge == 5:
			GalCost = GalCost * 3 / 2
		if Globals.EUHandler.is_bought(4):
			GalCost -= 10
		%Prestiges/GaButton.disabled = DimPurchase[7] < GalCost
		%Prestiges/GaLabel.text = "[center]Tachyon Galaxies (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % \
		[Globals.int_to_string(Globals.TGalaxies), Globals.int_to_string(GalCost), Globals.ordinal(8)]
	if Globals.Challenge == 8:
		if Globals.TDilation >= 5:
			%Prestiges/DiButton.disabled = true
			%Prestiges/DiButton.text = "Time Dilation capped\n(Challenge %s)" % Globals.int_to_string(8)
		%Prestiges/GaButton.disabled = true
		%Prestiges/GaButton.text = "Tachyon Galaxies disabled\n(Challenge %s)" % Globals.int_to_string(8)
	
	if not Input.is_action_pressed("ToggleAB"):
		for i in range(8, 0, -1):
			if Input.is_action_pressed("BuyTD%d" % i) or BuyMax:
				if dims[i].get_node("Buy/Progress").value >= \
				dims[i].get_node("Buy/Progress").max_value:
					buydim(i, INF if BuyMax else 0)
				elif Input.is_action_pressed("BuyOne"):
					buydim(i, 1)
		if Input.is_action_pressed("BuyTSpeed") or BuyMax:
			if TSpeedCost.less(Globals.Tachyons):
				buytspeed(true)
	
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
	
	BuyMax = Input.is_action_pressed("BuyMax")
	
	
	if Globals.Challenge == 10:
		if %Prestiges/DiButton.material == null:
			%Prestiges/DiButton.material = rewindNode.material.duplicate()
			%Prestiges/DiButton.material.set_shader_material("pixelsize", 1./250.)
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
			mult.mult2self(largenum.new(DilaBoost * 1.1).power(max(   C10Power   - i + 1, 0)))
		else:
			mult.mult2self(largenum.new(DilaBoost).power(max(Globals.TDilation - i + 1, 0)))
		
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
		
		if i == 8: mult.mult2self(RewindMult)
		
		if Globals.Challenge == 2: mult.mult2self(C2Multiplier)
		if Globals.Challenge == 3:
			if i == 3: mult.mult2self(3)
			if i <= 2: mult.mult2self(0.03)
		
		dims[i].get_node("N&M/Multiplier").text = "×%s" % mult.to_string()
		mult.mult2self(TSpeedBoost.power(TSpeedCount))
		
		if i != 8:
			if DimAmount[i].exponent == -INF:	dims[i].get_node("A&G/Growth").hide()
			else:								dims[i].get_node("A&G/Growth").show()
		if i == 1:
			TCperS = DimAmount[i-1].multiply(mult)
			Globals.Tachyons .add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
			Globals.TachTotal.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
		else:
			dims[i-1].get_node("A&G/Growth").text = "(+%s/s)" % \
				Globals.percent_to_string(DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_float())
			DimAmount[i-2].add2self(DimAmount[i-1].multiply(mult.multiply(delta)))