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

var DimAmount : Array[largenum] = [
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),largenum.new(0)
]
var DimPurchase : Array[int] = [0,0,0,0,0,0,0,0]
var DimCostStart : Array[largenum] = [
	largenum.ten_to_the( 4),largenum.ten_to_the( 6),
	largenum.ten_to_the(15),largenum.ten_to_the(30),
	largenum.ten_to_the(999),largenum.ten_to_the(999),
	largenum.ten_to_the(999),largenum.ten_to_the(999)
]
var DimCostMult : Array[largenum] :
	get:
		return [
			largenum.ten_to_the( 3),largenum.ten_to_the( 5),
			largenum.ten_to_the(10),largenum.ten_to_the(15),
			largenum.ten_to_the(20),largenum.ten_to_the(25),
			largenum.ten_to_the(30),largenum.ten_to_the(35)
		]

const TachLogReq := [
	1000, 1600, 4000, 10000, 1e100
]

var DimsUnlocked := 0
var TSperS       := largenum.new(0)
var TimeShards   := largenum.new(0)
var FreeTSpeed   := 0
var NextUpgrade  := largenum.new(1)
var TreshMult    : float :
	get:
		if FreeTSpeed < 200: return 1.1
		else:
			return 1.1 ** (softcap ** (FreeTSpeed - 200))
var softcap := 1.02
var BuyMax : bool

func dimcost(which):
	return DimCostStart[which-1].multiply(DimCostMult[which-1].power(DimPurchase[which-1]))

func buydim(which, bulk := 1):
	if which > DimsUnlocked: return
	Globals.EternityPts.add2self(dimcost(which).neg())
	if Globals.EternityPts.sign < 0:
		Globals.EternityPts.add2self(dimcost(which))
		return
	DimPurchase[which-1] += 1
	DimAmount[which-1].add2self(largenum.new(bulk))
	if not Globals.Achievemer.is_unlocked(2, 7):
		if bulk == 1 and which == 1 and DimAmount[which-1].log10() >= 100:
			Globals.Achievemer.set_unlocked(2, 7)

func _process(delta):
	#for i in 8:
		#DimPurchase[i] = 0
	for k in range(1, len(dims)):
		var i = dims[k]
		if i == null: continue
		if k > DimsUnlocked + 1:
			i.hide()
		else:
			i.show()
		if k == DimsUnlocked + 1:
			i.modulate.a = 0.5
		else:
			i.modulate.a = 1
		i.get_node("Buy").tooltip_text = "Purchased %s time%s" % \
		[Globals.int_to_string(DimPurchase[k-1]), "" if DimPurchase[k-1] == 1 else "s"]
		i.get_node("Buy").disabled = Globals.EternityPts.less(dimcost(k))
		i.get_node("A&G/Amount").text = DimAmount[k-1].to_string()
		i.get_node("Buy").text = "Cost: %s EP" % dimcost(k).to_string()
	
	var buy10mult = 4
	
	%Important.text = "[center]%s [font_size=20]%s[/font_size] %s [font_size=20]%s[/font_size] %s" % [
		"You have", TimeShards.to_string(), "Time Shards, giving",
		Globals.int_to_string(FreeTSpeed), "free Timespeed Upgrades."
	]
	%Important.text += "\n%s [font_size=20]%s[/font_size] %s [font_size=20]×%s[/font_size] %s" % [
		"Next upgrade at", NextUpgrade.to_string(), "Time Shards, increasing by",
		Globals.float_to_string(TreshMult), "for each Upgrade."
	]
	%Important.text += "\n[font_size=10]%s [/font_size]%s[font_size=10] %s" % [
		"You're gaining", TSperS.to_string(), "Time Shards per second."
	]
	
	if Globals.ECCompleted(2):
		%Important.text += " | Timespeed: [/font_size]%s[font_size=10]/sec" % \
		Globals.float_to_string(Formulas.ec2_reward())
	
	while not TimeShards.less(NextUpgrade):
		NextUpgrade.mult2self(TreshMult)
		FreeTSpeed += 1
	
	if false:
		if not Input.is_action_pressed("ToggleAB"):
			for i in range(8, 0, -1):
				if Input.is_action_pressed("BuyTD%d" % i) or BuyMax:
					if Input.is_action_pressed("BuyOne"):
						buydim(i, 1)
					elif dims[i].get_node("Buy/Progress").value >= \
					dims[i].get_node("Buy/Progress").max_value:
						buydim(i, 0)
						if BuyMax:
							buydim(i, 1e9)
	BuyMax = Input.is_action_pressed("BuyMax")
	
	for i in 8:
		dims[i+1].get_node("N&M/Name").text = "%s Eternity Dimension" % Globals.ordinal(i+1)
	
	if DimsUnlocked < 8:
		dims[DimsUnlocked + 1].get_node("A&G/Growth").hide()
		dims[DimsUnlocked + 1].get_node("N&M/Multiplier").hide()
		dims[DimsUnlocked + 1].get_node("Buy").disabled = true
	
	for i in range(1, min(DimsUnlocked+1, len(dims))):
		var mult := largenum.new(1)
		
		mult.mult2self(largenum.new(buy10mult).power(DimPurchase[i-1]))
		
		if Globals.ECCompleted(1):
			mult.mult2self(Formulas.ec1_reward())
		
		if Globals.Challenge == 17:
			mult.pow2self(0.2)
		
		dims[i].get_node("N&M/Multiplier").text = "×%s" % mult.to_string()
		dims[i].get_node("N&M/Multiplier").show()
		
		if Globals.ECCompleted(2):
			mult.mult2self(Formulas.ec2_reward())
		
		if i != 8:
			if DimAmount[i].exponent == -INF:	dims[i].get_node("A&G/Growth").hide()
			else:								dims[i].get_node("A&G/Growth").show()
		if i == 1:
			TSperS = DimAmount[i-1].multiply(mult)
			TimeShards.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
		else:
			if DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).less(10):
				dims[i-1].get_node("A&G/Growth").text = "(+%s/s)" % \
				Globals.percent_to_string(DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_float())
			else:
				dims[i-1].get_node("A&G/Growth").text = "(×%s/s)" % \
				DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_string()
			DimAmount[i-2].add2self(DimAmount[i-1].multiply(mult.multiply(delta)))

func eternitied():
	TimeShards = largenum.new(0)
	FreeTSpeed = 0
	NextUpgrade = largenum.new(1)
	for i in 8:
		DimAmount[i] = largenum.new(DimPurchase[i])

func unlocknewdim():
	DimsUnlocked += 1
