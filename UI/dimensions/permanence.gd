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

func _ready() -> void:
	for i in range(1, len(dims)):
		dims[i].get_node("Buy").connect("pressed", PermaDims.buydim.bind(i))

func _process(delta):
	for k in range(1, len(dims)):
		var i = dims[k]
		if i == null: continue
		if k > PermaDims.DimsUnlocked + 1:
			i.hide()
		else:
			i.show()
		if k == PermaDims.DimsUnlocked + 1:
			i.modulate.a = 0.5
		else:
			i.modulate.a = 1
		i.get_node("Buy").tooltip_text = "Purchased %s time%s" % [
			Globals.int_to_string(PermaDims.DimPurchase[k-1]),
			"" if PermaDims.DimPurchase[k-1] == 1 else "s"]
		i.get_node("Buy").disabled = Currencies.PermanencePts.AMOUNT.less(PermaDims.dimcost(k))
		if k < 8:
			i.get_node("A&G/Amount").text = PermaDims.DimAmount[k-1].to_string().\
			trim_suffix(".00").trim_suffix(";00")
		else:
			i.get_node("A&G/Amount").text = \
			Globals.int_to_string(PermaDims.DimPurchase[k-1])
		i.get_node("Buy").text = "Cost: %s EP" % \
		PermaDims.dimcost(k).to_string().\
		replace(".00", "").trim_suffix(";00")
	
	for i in 8:
		dims[i+1].get_node("N&M/Name").text = \
		"%s Eternity Dimension" % Globals.ordinal(i+1)
		dims[PermaDims.DimsUnlocked + 1].get_node("N&M/Multiplier").show()
		if i != 8:
			if PermaDims.DimAmount[i].exponent == -INF:
				dims[i+1].get_node("A&G/Growth").hide()
			else:
				dims[i+1].get_node("A&G/Growth").show()
	
	if PermaDims.DimsUnlocked < 8:
		dims[PermaDims.DimsUnlocked + 1].get_node("A&G/Growth").hide()
		dims[PermaDims.DimsUnlocked + 1].get_node("N&M/Multiplier").hide()
		dims[PermaDims.DimsUnlocked + 1].get_node("Buy").disabled = true
	
	%Important.text = "[center]%s [font_size=20]%s[/font_size] %s [font_size=20]%s[/font_size] %s" % [
		"You have", PermaDims.TimeShards.to_string(), "Time Shards, giving",
		Globals.int_to_string(PermaDims.FreeTSpeed), "free Timespeed Upgrades."
	]
	%Important.text += "\n%s [font_size=20]%s[/font_size] %s [font_size=20]×%s[/font_size] %s" % [
		"Next upgrade at", PermaDims.NextUpgrade.to_string(), "Time Shards, increasing by",
		Globals.float_to_string(PermaDims.TreshMult), "for each Upgrade."
	]
	%Important.text += "\n[font_size=10]%s [/font_size]%s[font_size=10] %s" % [
		"You're gaining", PermaDims.TSperS.to_string(), "Time Shards per second."
	]
	
	if Globals.ECCompleted(6):
		%Label.text = "%s ×%s. %s ×%s %s %s %s ×%s %s %s %s." % [
			"The requirement for free Timespeed upgrades starts at",
			Globals.float_to_string(1.1), "It jumps to",
			Globals.float_to_string(1.75), "at", Globals.int_to_string(308),
			"upgrades and to", Globals.float_to_string(4.375), "at",
			Globals.int_to_string(4000), "upgrades"
		]
	else:
		%Label.text = "%s ×%s. %s ×%s %s %s %s ×%s %s %s %s." % [
			"The requirement for free Timespeed upgrades starts at",
			Globals.float_to_string(1.1), "It jumps to",
			Globals.float_to_string(2), "at", Globals.int_to_string(308),
			"upgrades and to", Globals.float_to_string(5), "at",
			Globals.int_to_string(4000), "upgrades"
		]
	
	if Globals.ECCompleted(2):
		%Important.text += " | Timespeed: [/font_size]%s[font_size=10]/sec" % \
		Globals.float_to_string(Formulas.ec2_reward())
	
