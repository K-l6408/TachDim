extends Control

@onready var dims : Array[HBoxContainer] = [
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

func _ready():
	# connecting signals
	for k in 8:
		var i = dims[k]
		i.get_node("Buy").connect("pressed", func():
			if %TopButtons/BuyMode.button_pressed:
				TachyonDims.buy_until_mult(k+1)
			else:
				TachyonDims.buy_one(k+1)
		)
	
	%TopButtons/Timespeed.connect("pressed", TachyonDims.buy_tspeed)
	%TopButtons/Timespeed/BuyMax.connect("pressed", TachyonDims.buy_max_tspeed)
	%TopButtons/BuyMax.connect("pressed", func():
		for i in 8:
			TachyonDims.buy_max(i+1)
		TachyonDims.buy_max_tspeed()
	)
	
	%Prestiges/DiButton.connect("pressed", TachyonDims.dilate)
	%Prestiges/GaButton.connect("pressed", TachyonDims.galaxy)
	%Prestiges/Reset.connect("pressed", TachyonDims.antisoftlock)
	
	$"BIG BANG".connect("pressed", TachyonDims.permanence)

func _process(delta):
	var logfinity = 2048 if Globals.Challenge == 15 else 1024
	
	#if canBigBang and Input.is_action_pressed("BBang"):
		#Permanence()
	
	if Globals.progressBL < GL.Progression.Overcome or \
	(Globals.Challenge != 0 and Globals.Challenge <= 15):
		$VSplitContainer.visible = (Currencies.Tachyons.AMOUNT.log2() <= logfinity)
		$"BIG BANG".visible      = (Currencies.Tachyons.AMOUNT.log2() >= logfinity)
		
		if TachyonDims.canBigBang:
			custom_minimum_size.y = $"BIG BANG".size.y
			return
	else:
		$VSplitContainer.visible = true
		$"BIG BANG".visible = false
	custom_minimum_size.y = $VSplitContainer.size.y
	
	for k in 8:
		var i = dims[k]
		
		if k > TachyonDims.DimsUnlocked:	i.hide()
		else:								i.show()
		
		i.get_node("Buy").tooltip_text = "Purchased %s time%s" % [
			Globals.int_to_string(TachyonDims.DimPurchase[k]),
			"" if TachyonDims.DimPurchase[k] == 1 else "s"
		]
		
		var buyable = (
			Currencies.Tachyons.AMOUNT.divide(TachyonDims.dimcost(k+1))
		).to_float()
		if abs(buyable) > TachyonDims.buylim:
			buyable = TachyonDims.buylim
		buyable = int(buyable)
		i.get_node("Buy/Progress").value = buyable
		i.get_node("Buy/Progress").max_value = \
		TachyonDims.buylim - TachyonDims.DimPurchase[k] % TachyonDims.buylim
		
		i.get_node("Buy").disabled = \
		not TachyonDims.dimcost(k+1).less(Currencies.Tachyons.AMOUNT)
		
		if k+1 < TachyonDims.DimsUnlocked:
			i.get_node("A&G/Amount").text = \
			TachyonDims.DimAmount[k].to_string().trim_suffix(".00").trim_suffix(";00")
		else:
			i.get_node("A&G/Amount").text = \
			Globals.int_to_string(TachyonDims.DimPurchase[k])
		
		i.get_node("Buy").text = "Buy %s\nCost: %s TC" % [
			Globals.int_to_string(min(buyable,
				TachyonDims.buylim - TachyonDims.DimPurchase[k] % TachyonDims.buylim)),
			TachyonDims.dimcost(k+1).multiply(min(max(buyable, 1),
				TachyonDims.buylim - TachyonDims.DimPurchase[k] % TachyonDims.buylim)
			).to_string()
		]
		
		i.get_node("N&M/Name").text = "%s Tachyon Dimension" % Globals.ordinal(k+1)
		i.get_node("N&M/Multiplier").text = "×%s" % TachyonDims.Multipliers[k].to_string()
		if k != 7:
			if k+1 >= TachyonDims.DimsUnlocked or TachyonDims.DimAmount[k+1].exponent == -INF:
				i.get_node("A&G/Growth").hide()
			else:
				i.get_node("A&G/Growth").show()
				i.get_node("A&G/Growth").text = "(+%s)" % \
				Globals.percent_to_string(
					TachyonDims.Multipliers[k+1].multiply(
						TachyonDims.TSpeedBoost.power(
							TachyonDims.TSpeedCount + Globals.EDHandler.FreeTSpeed
						).multiply(TachyonDims.DimAmount[k+1])
					).divide(TachyonDims.DimAmount[k]).to_float()
				)
		
		if k != 0:
			if TachyonDims.DimAmount[k-1].exponent == -INF\
			or k >= TachyonDims.DimsUnlocked:
				i.get_node("Buy").disabled = true
				i.modulate.a = 0.5
				i.get_node("N&M/Multiplier").hide()
			else:
				i.modulate.a = 1.0
				i.get_node("N&M/Multiplier").show()
		
		if Input.is_action_pressed("BuyTD%d" % (k+1)):
			if Input.is_action_pressed("BuyOne"):
				TachyonDims.buy_one(k+1)
			else:
				TachyonDims.buy_until_mult(k+1, true)
	
	if Input.is_action_pressed("BuyMax"):
		for i in 8:
			TachyonDims.buy_max(i+1)
		TachyonDims.buy_max_tspeed()
	
	if Globals.Challenge == 20:
		%TopButtons/Timespeed.disabled = true
		%TopButtons/Timespeed/BuyMax.disabled = true
		%TopButtons/Timespeed.text = "Timespeed disabled (EC5)"
	else:
		%TopButtons/Timespeed.disabled = Currencies.Tachyons.AMOUNT.less(TachyonDims.tspcost())
		%TopButtons/Timespeed/BuyMax.disabled = Currencies.Tachyons.AMOUNT.less(TachyonDims.tspcost())
		%TopButtons/Timespeed.text = "Timespeed (%s TC) " % TachyonDims.tspcost().to_string()
	%TopButtons/Timespeed.tooltip_text = "Purchased %s time%s" % \
	[Globals.int_to_string(TachyonDims.TSpeedCount), "" if TachyonDims.TSpeedCount == 1 else "s"]
	if Globals.EDHandler.DimsUnlocked > 0:
		%TopButtons/Timespeed.tooltip_text += " + %s Free upgrade%s" % [
			Globals.int_to_string(Globals.EDHandler.FreeTSpeed),
			"" if Globals.EDHandler.FreeTSpeed == 1 else "s"
		]
	%TopButtons/BuyMode.text = \
	"Buy until %s" % Globals.int_to_string(TachyonDims.buylim) if %TopButtons/BuyMode.button_pressed else "Buy singles"
	if Globals.display == Globals.DisplayMode.Dozenal:
		%Progress.tooltip_text = "Pergrossage to "
	else:
		%Progress.tooltip_text = "Percentage to "
	if Globals.Challenge <= 15:
		%Progress.value = Currencies.Tachyons.AMOUNT.log2()
		%Progress.max_value = logfinity
		%Progress.tooltip_text += "Permanence"
	else:
		%Progress.value = Currencies.Tachyons.AMOUNT.log2()
		%Progress.max_value = Globals.ECTargets[Globals.Challenge - 16].log2()
		%Progress.tooltip_text += "Challenge goal"
	%Progress/Label.text = Globals.percent_to_string(%Progress.value / %Progress.max_value, 1)
	%Progress/Label.add_theme_color_override("font_color", get_theme_color("font_color", "ProgressBar"))
	rewindNode.visible = (TachyonDims.TDilation >= 5) or \
	(Globals.progress >= Globals.Progression.Galaxy)
	
	%Important.text = \
	"[center]You have [font_size=20]" + Currencies.Tachyons.to_string() + \
	"[/font_size] Tachyons.\n[font_size=10]You're gaining [/font_size]" + \
	TachyonDims.Multipliers[0].multiply(TachyonDims.DimAmount[0]).\
	multiply(Currencies.Tachyons.mults["Timespeed"].power).to_string() + \
	"[font_size=10] Tachyons per second.[/font_size]\n[font_size=10]Timespeed strength: [/font_size]" + \
	TachyonDims.TSpeedBoost.to_string() + "[font_size=10] | Total speed: [/font_size]" + \
	TachyonDims.TSpeedBoost.power(
		TachyonDims.TSpeedCount + Globals.EDHandler.FreeTSpeed).to_string() + \
	"[font_size=10]/sec\nBuy " + Globals.int_to_string(TachyonDims.buylim) + " multiplier: [/font_size]" + \
	Globals.float_to_string(TachyonDims.buymult)
	
	if rewindNode.visible:
		%Important.text += "[font_size=10] | Rewind multiplier: [/font_size]" + TachyonDims.RewindMult.to_string()
	
	if Globals.Challenge == 2:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]" + \
		Globals.percent_to_string(TachyonDims.C2Multiplier)
	if Globals.Challenge == 3:
		%Important.text += "\n \n[font_size=10]%s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(3), Globals.int_to_string(3)]
		%Important.text += "\n[font_size=10]%s and %s Dimension: [/font_size]×%s" % \
		[Globals.ordinal(2), Globals.ordinal(1), Globals.float_to_string(0.03)]
	if Globals.Challenge == 9:
		%Important.text += "\n \n[font_size=10]Dimensions %s-%s: [/font_size]/" % [
			Globals.int_to_string(1), Globals.int_to_string(7)
		] + Currencies.Tachyons.AMOUNT.power(0.05).to_string()
	if Globals.Challenge == 14:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/" + \
		Globals.float_to_string(TachyonDims.C14Divisor)
	if Globals.Challenge == 16:
		%Important.text += "\n \n[font_size=10]Production: [/font_size]/" + \
		Globals.float_to_string(TachyonDims.C14Divisor) + ", " + \
		Globals.percent_to_string(TachyonDims.C2Multiplier)
	if %Prestiges/DiButton.material != null:
		%Prestiges/DiButton.material.\
		set_shader_parameter("disabled", %Prestiges/DiButton.disabled)
	
	if TachyonDims.TDilation < 5 and Globals.Challenge != 13:
		rewindNode.text = "Dimensional Rewind disabled (requires %s Time Dilation) " % \
		Globals.int_to_string(5)
	elif TachyonDims.DimAmount[7].exponent == -INF and Globals.Challenge != 13:
		rewindNode.text = "Dimensional Rewind disabled (no %s TD)" % \
		Globals.ordinal(8)
	elif TachyonDims.rewindBoost().less(TachyonDims.RewindMult):
		rewindNode.text = "Dimensional Rewind disabled (×%s multiplier)" % \
		Globals.int_to_string(1)
	else:
		if Globals.Challenge == 13:
			rewindNode.text = "Dimensional Rewind (×%s to all TDs)" % [
				TachyonDims.rewindBoost().\
				divide(TachyonDims.RewindMult).to_string()
			]
		else:
			rewindNode.text = "Dimensional Rewind (×%s to %s TD)" % [
				TachyonDims.rewindBoost().\
				divide(TachyonDims.RewindMult).to_string(), Globals.ordinal(8)
			]
		if Input.is_action_pressed("Rewind"):
			TachyonDims.rewind()
	
	%Prestiges/GaButton.text = "Reset your Dimensions and\n" + \
	"Time Dilation to boost the power\nof Timespeed upgrades"
	
	if Globals.Challenge == 6 or Globals.Challenge == 16:
		if TachyonDims.DimsUnlocked < 6:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % \
			Globals.ordinal(TachyonDims.DimsUnlocked + 1) +\
			" and\ngain a ×%s multiplier to Dimension%s" % [
				TachyonDims.dilamult.to_string(),
				(
					"s %s-%s" % [Globals.int_to_string(1),
					Globals.int_to_string(TachyonDims.TDilation + 1)] \
					if TachyonDims.TDilation != 0 \
					else " " + Globals.int_to_string(1)
				)
			]
		else:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions"
			if not TachyonDims.dilamult.less(1.1):
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to %s" % [
					TachyonDims.dilamult.to_string(),
					("all Dimensions" if TachyonDims.TDilation >= 5 else "Dimensions 1-%d" % (TachyonDims.TDilation + 1))
				]
	else:
		if TachyonDims.TDilation == 4:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock Rewind"
			if not TachyonDims.dilamult.less(1.1):
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					TachyonDims.dilamult.to_string(),
					("s %s-%s" % [
						Globals.int_to_string(1),
						Globals.int_to_string(TachyonDims.TDilation + 1)
					]if TachyonDims.TDilation != 0 else " " + Globals.int_to_string(1))
				]
		elif TachyonDims.TDilation < 0:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(TachyonDims.DimsUnlocked + 1)
		elif TachyonDims.TDilation >= 5:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions"
			if not TachyonDims.dilamult.less(1.1):
				%Prestiges/DiButton.text += " to\ngain a ×%s multiplier to all Dimensions" % \
				TachyonDims.dilamult.to_string()
		else:
			%Prestiges/DiButton.text = \
			"Reset your Dimensions to\nunlock the %s Dimension" % Globals.ordinal(TachyonDims.DimsUnlocked + 1)
			if not TachyonDims.dilamult.less(1.1):
				%Prestiges/DiButton.text += " and\ngain a ×%s multiplier to Dimension%s" %\
				[
					TachyonDims.dilamult.to_string(),
					("s %s-%s" % [
						Globals.int_to_string(1),
						Globals.int_to_string(TachyonDims.TDilation + 1)
					]if TachyonDims.TDilation != 0 else " " + Globals.int_to_string(1))
				]
	
	%Prestiges/DiButton.disabled = not TachyonDims.canDilate
	%Prestiges/DiLabel.text = \
	"[center]Time Dilation (%s)\n[font_size=2] \n[font_size=10]Requires: %s %s Tachyon Dimensions" % [
		Globals.int_to_string(TachyonDims.TDilation),
		Globals.int_to_string(TachyonDims.dilacost()),
		Globals.ordinal(TachyonDims.DimsUnlocked)
	]
	
	
	%Prestiges/GaButton.disabled = not TachyonDims.canGalaxy
	%Prestiges/GaLabel.text = "[center]%sTachyon Galaxies (%s)\n%s[font_size=10]Requires: %s %s Tachyon Dimensions%s" % [
		("" if TachyonDims.TGalaxies < TachyonDims.DistantScaling else "Distant "),
		(
			"%s + %s" % [
				Globals.int_to_string(TachyonDims.TGalaxies),
				Globals.int_to_string(Globals.DupHandler.dupGalaxies)
			]
			if Globals.DupHandler.dupGalaxies > 0 else
			"%s" % Globals.int_to_string(TachyonDims.TGalaxies)
		),
		("[font_size=2] \n" if TachyonDims.TGalaxies < TachyonDims.DistantScaling else ""),
		Globals.int_to_string(TachyonDims.galacost()),
		Globals.ordinal(
			6 if (Globals.Challenge == 6 or Globals.Challenge == 16) else 8),
		("" if TachyonDims.TGalaxies < TachyonDims.DistantScaling else 
		"\nEvery Galaxy is more expensive after %s Galaxies" %
		Globals.int_to_string(TachyonDims.DistantScaling))
	]
	
	if Globals.Challenge == 8:
		if TachyonDims.TDilation >= 5:
			%Prestiges/DiButton.disabled = true
			%Prestiges/DiButton.text = "Time Dilation capped\n(Challenge %s)" % Globals.int_to_string(8)
		%Prestiges/GaButton.disabled = true
		%Prestiges/GaButton.text = "Tachyon Galaxies disabled\n(Challenge %s)" % Globals.int_to_string(8)
	
	if Globals.Challenge == 22:
		%Prestiges/GaButton.disabled = true
		%Prestiges/GaButton.text = "Tachyon Galaxies disabled\n(Permanence Challenge %s)" % \
		Globals.int_to_string(7)
	%Prestiges/Reset.visible = (Globals.Challenge in [14, 18, 19]) and \
	TachyonDims.TDilation > -3
	
	#if not Input.is_action_pressed("ToggleAB"):
		#for i in range(8, 0, -1):
			#if Input.is_action_pressed("BuyTD%d" % i) or BuyMax:
				#if Input.is_action_pressed("BuyOne") and not BuyMax:
					#buydim(i, 1)
				#elif dims[i].get_node("Buy/Progress").value >= \
				#dims[i].get_node("Buy/Progress").max_value:
					#buydim(i, 0)
					#if BuyMax:
						#buydim(i, 1e9)
		#if Input.is_action_pressed("BuyTSpeed") or BuyMax:
			#if tspcost().less(Currencies.Tachyons.AMOUNT):
				#buytspeed(not Input.is_action_pressed("BuyOne") or BuyMax)
	#BuyMax = Input.is_action_pressed("BuyMax")
	#if Input.is_action_pressed("Dilate"):
		#if not %Prestiges/DiButton.disabled:
			#dilate()
	#if Input.is_action_pressed("Galaxy"):
		#if not %Prestiges/GaButton.disabled:
			#galaxy()
	#if Input.is_action_pressed("BBang"):
		#if $"BIG BANG".visible:
			#Permanence()
	
	if Globals.Challenge == 10:
		if %Prestiges/DiButton.material == null:
			%Prestiges/DiButton.material = rewindNode.material.duplicate()
		%Prestiges/DiButton.material.set_shader_parameter(
			"pixelsize", 1./250.
		)
		%Prestiges/DiButton/Accuracy.visible = true
		%Prestiges/DiButton/Accuracy.position.x = (
			(TachyonDims.C10Score() * 230) + 240
		) / 2
	else:
		%Prestiges/DiButton/Accuracy.visible = false
		%Prestiges/DiButton.material = null
