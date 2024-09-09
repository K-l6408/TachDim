extends Control

var TCST := 0
var EPST := 0
var BPST := 0
var ST := largenum.new(0)

var purchased : PackedStringArray = []

func theorem_cost_tc():
	return largenum.ten_to_the(20000 * (TCST + 1))
func theorem_cost_ep():
	return largenum.ten_to_the(100 * (EPST + 1))
func theorem_cost_bp():
	return largenum.two_to_the(BPST + 1)

func theorem_buy(how):
	match how:
		0:
			Globals.Tachyons.add2self(theorem_cost_tc().neg())
			TCST += 1
			ST.add2self(1)
		1:
			Globals.EternityPts.add2self(theorem_cost_ep().neg())
			EPST += 1
			ST.add2self(1)
		2:
			Globals.BoundlessPts.add2self(theorem_cost_bp().neg())
			BPST += 1
			ST.add2self(1)
		3:
			while Globals.Tachyons.less(theorem_cost_tc()):
				theorem_buy(0)
			while Globals.EternityPts.less(theorem_cost_ep()):
				theorem_buy(1)
			while Globals.BoundlessPts.less(theorem_cost_bp()):
				theorem_buy(2)

func _ready():
	for tree in %Trees.get_children():
		for i in tree.get_children():
			if i is Study:
				i.connect("pressed", buy_study.bind(i))

func _process(_delta):
	$ST/Buy/TC.text = " Cost: %s TC " % \
	theorem_cost_tc().to_string().replace(".00", "")
	$ST/Buy/TC.disabled = not theorem_cost_tc().less(Globals.Tachyons)
	
	$ST/Buy/EP.text = " Cost: %s EP " % \
	theorem_cost_ep().to_string().replace(".00", "")
	$ST/Buy/EP.disabled = not theorem_cost_ep().less(Globals.EternityPts)
	
	$ST/Buy/BP.text = " Cost: %s BP " % \
	theorem_cost_bp().to_string()
	$ST/Buy/BP.disabled = not theorem_cost_bp().less(Globals.BoundlessPts)
	
	$ST/Buy/Max.disabled = (
		$ST/Buy/TC.disabled and $ST/Buy/EP.disabled and $ST/Buy/BP.disabled
	)
	
	$ST/Amount.text = "%s Space Theorems" % ST.to_string()
	
	%StudyTree1/SD1.text = "\n\nUnlock the %s\nSpace Dimension.\n\n" % \
	Globals.ordinal(1)
	
	%StudyTree1/DupM.text = "\nImprove Duplicantes'\nmultiplier.\n\n" + \
	"Currently: ×%s\n\n" % \
	Formulas.dupli_yes11().divide(Formulas.dupli_no11()).to_string()
	
	%StudyTree1/DupSp.text = \
	"\n\nYou gain Duplicantes\n%s times faster.\n\n\n" % Globals.int_to_string(3)
	
	%StudyTree1/Dila2Eter.text = "\nTime Dilation boosts\nEternity gain.\n\n" + \
	"Currently: ×%s\n\n" % Globals.int_to_string(max(Globals.TDilation, 1))
	
	%StudyTree1/EtMultPow.text = "\nMultipliers based on\nEternities are\n" + \
	"raised ^%s.\n\n\n" % Globals.float_to_string(4)
	
	%StudyTree1/TGScaling.text = "\n%s\n%s %s %s\n%s %s.\n\n\n" % [
		"Tachyon Galaxy costs", "scale by", Globals.int_to_string(40),
		"Dimensions", "instead of", Globals.int_to_string(60)
	]
	
	%StudyTree1/TG2EP.text = \
	"\nEach Tachyon Galaxy\ngives a ×%s\nmultiplier to\nEP gained.\n\n" % \
	Globals.float_to_string(1.4)
	
	for i in %StudyTree1.get_children():
		if i is Study:
			i.text += "Cost: %s Space Theorems" % Globals.int_to_string(i.cost)

func respec():
	for id in purchased:
		find_study(id).bought = false
	purchased = []
	ST = largenum.new(TCST + EPST + BPST)

func buy_study(which):
	if which is Study:
		ST.add2self(-which.cost)
		purchased.append(which.id_label.text)
		which.bought = true
	if which is String:
		return buy_study(find_study(which))

func find_study(id:String):
	for tree in %Trees.get_children():
		for i in tree.get_children():
			if i is Study:
				if i.id_label.text == id:
					return i
