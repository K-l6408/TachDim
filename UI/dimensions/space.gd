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
	largenum.new( 1),largenum.new(5),
	largenum.ten_to_the(3),
	largenum.new(0),largenum.new(0),
	largenum.new(0),largenum.new(0),largenum.new(0),
]
var DimCostMult : Array[largenum] :
	get:
		return [
			largenum.new( 3),largenum.ten_to_the(1),
			largenum.new(27),
			largenum.new(0),largenum.new(0),
			largenum.new(0),largenum.new(0),largenum.new(0),
		]

var DimsUnlocked := 0
var BLPperS        := largenum.new(0)
var BoundlessPower := largenum.new(0)
var BuyMax : bool

func dimcost(which):
	return DimCostStart[which-1].\
	multiply(DimCostMult[which-1].power(DimPurchase[which-1]))

func buydim(which):
	if which > DimsUnlocked: return
	Globals.BoundlessPts.add2self(dimcost(which).neg())
	if abs(Globals.BoundlessPts.to_float()) < 0.1:
		Globals.BoundlessPts = largenum.new(0)
	if Globals.BoundlessPts.sign < 0:
		Globals.BoundlessPts.add2self(dimcost(which))
		return
	DimPurchase[which-1] += 1
	DimAmount[which-1].add2self(1)

func _process(delta):
	DimsUnlocked = 0
	for i in 8:
		if "SD%d"%(i+1) in Globals.Studies.purchased:
			DimsUnlocked = i+1
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
		i.get_node("Buy").disabled = \
		abs(dimcost(k).add(Globals.BoundlessPts.neg()).to_float()) > 0.1\
		and Globals.BoundlessPts.less(dimcost(k))
		i.get_node("A&G/Amount").text = DimAmount[k-1].to_string().\
		trim_suffix(".00").trim_suffix(";00")
		#print(DimAmount[k-1].to_float())
		i.get_node("Buy").text = "Cost: %s BP" % dimcost(k).to_string().\
		replace(".00", "").trim_suffix(";00")
	
	var buymult = 5
	
	%Important.text = \
	"[center]%s [font_size=20]%s[/font_size] %s [font_size=20]^%s[/font_size] %s [font_size=20]×%s[/font_size]." % [
		"You have", BoundlessPower.to_string(), "Boundless Power,\nraised",
		Globals.float_to_string(Formulas.boundlessconversion(), 3),
		"to boost Time Dilation's multiplier by", Formulas.bounlesspower().to_string()
	]
	%Important.text += "\n[font_size=10]%s [/font_size]%s[font_size=10] %s" % [
		"You're gaining", BLPperS.to_string(), "Boundless Power per second."
	]
	
	#if false:
		#if not Input.is_action_pressed("ToggleAB"):
			#for i in range(8, 0, -1):
				#if Input.is_action_pressed("BuyTD%d" % i) or BuyMax:
					#buydim(i)
					#if BuyMax:
						#buydim(i)
	#BuyMax = Input.is_action_pressed("BuyMax")
	
	for i in 8:
		dims[i+1].get_node("N&M/Name").text = "%s Space Dimension" % Globals.ordinal(i+1)
	
	if DimsUnlocked < 8:
		dims[DimsUnlocked + 1].get_node("A&G/Growth").hide()
		dims[DimsUnlocked + 1].get_node("N&M/Multiplier").hide()
		dims[DimsUnlocked + 1].get_node("Buy").disabled = true
	
	for i in range(1, min(DimsUnlocked+1, len(dims))):
		var mult := largenum.new(1)
		
		mult.mult2self(largenum.new(buymult).power(DimPurchase[i-1]))
		
		if i == 2 and "Space1" in Globals.Studies.purchased:
			mult.mult2self(Formulas.study_space1())
		
		if "Space2" in Globals.Studies.purchased:
			mult.mult2self(Formulas.study_space2())
		if "Space3" in Globals.Studies.purchased:
			mult.mult2self(max(Globals.DupHandler.dupGalaxies, 1))
		
		dims[i].get_node("N&M/Multiplier").text = "×%s" % mult.to_string()
		dims[i].get_node("N&M/Multiplier").show()
		
		if i != 8:
			if DimAmount[i].exponent == -INF:	dims[i].get_node("A&G/Growth").hide()
			else:								dims[i].get_node("A&G/Growth").show()
		if i == 1:
			BLPperS = DimAmount[i-1].multiply(mult)
			BoundlessPower.add2self(DimAmount[i-1].multiply(mult.multiply(delta)))
		else:
			if DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).less(10):
				dims[i-1].get_node("A&G/Growth").text = "(+%s/s)" % \
				Globals.percent_to_string(DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_float())
			else:
				dims[i-1].get_node("A&G/Growth").text = "(×%s/s)" % \
				DimAmount[i-1].multiply(mult).divide(DimAmount[i-2]).to_string()
			DimAmount[i-2].add2self(DimAmount[i-1].multiply(mult.multiply(delta)))

func boundlessed():
	BoundlessPower = largenum.new(0)
	for i in 8:
		DimAmount[i] = largenum.new(DimPurchase[i])
