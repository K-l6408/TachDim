extends Control

var TCST := 0
var EPST := 0
var BPST := 0
var ST := largenum.new(0)

var purchased : PackedStringArray = []
var respecing : bool :
	get: return $Respec.button_pressed

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
			while theorem_cost_tc().less(Globals.Tachyons):
				theorem_buy(0)
			while theorem_cost_ep().less(Globals.EternityPts):
				theorem_buy(1)
			while theorem_cost_bp().less(Globals.BoundlessPts):
				theorem_buy(2)

func on_reset():
	if respecing:
		var sds = Globals.SDHandler.DimsUnlocked
		respec()
		for i in sds:
			buy_study("SD%d" % (i + 1))

func _ready():
	for tree in %Trees.get_children():
		for i in tree.get_children():
			if i is Study:
				i.connect("pressed", buy_study.bind(i))

func _process(_delta):
	$ST/Buy/TC.text = " Cost: %s TC " % \
	theorem_cost_tc().to_string().replace(".00e", "e").replace("00e", "e")\
	.trim_suffix(".00").trim_suffix(";00")
	$ST/Buy/TC.disabled = not theorem_cost_tc().less(Globals.Tachyons)
	
	$ST/Buy/EP.text = " Cost: %s EP " % \
	theorem_cost_ep().to_string().replace(".00e", "e").replace(";00e", "e")\
	.trim_suffix(".00").trim_suffix(";00")
	$ST/Buy/EP.disabled = not theorem_cost_ep().less(Globals.EternityPts)
	
	$ST/Buy/BP.text = " Cost: %s BP " % \
	theorem_cost_bp().to_string().trim_suffix(".00").trim_suffix(";00")
	$ST/Buy/BP.disabled = not theorem_cost_bp().less(Globals.BoundlessPts)
	
	$ST/Buy/Max.disabled = (
		$ST/Buy/TC.disabled and $ST/Buy/EP.disabled and $ST/Buy/BP.disabled
	)
	
	$ST/Amount.text = "%s Space Theorem%s" % [
		ST.to_string().trim_suffix(".00").trim_suffix(";00"),
		"" if ST.exponent == 0 else "s"
	]
	
	
	%StudyTree1/SD1.text = "\nUnlock the %s\nSpace Dimension.\n\n\n" % \
	Globals.ordinal(1)
	
	%StudyTree1/DupM.text = "\nImprove Duplicantes'\nmultiplier.\n\n" + \
	"Currently: ×%s\n\n" % \
	Formulas.dupli_yes11().divide(Formulas.dupli_no11()).to_string()
	
	%StudyTree1/DupSp.text = \
	"\n\nYou gain Duplicantes\n%s times faster.\n\n\n" % Globals.int_to_string(5)
	
	%StudyTree1/Dila2Eter.text = "\nTime Dilation boosts\nEternity gain.\n\n" + \
	"Currently: ×%s\n\n" % Globals.int_to_string(max(Globals.TDilation, 1))
	
	%StudyTree1/EtMultPow.text = "\nMultipliers based on\nEternities are\n" + \
	"raised ^%s.\n\n\n" % Globals.float_to_string(4)
	
	%StudyTree1/TGScaling.text = "\n%s\n%s %s %s\n%s %s.\n\n\n" % [
		"Tachyon Galaxy costs", "scale by", Globals.int_to_string(55),
		"Dimensions", "instead of", Globals.int_to_string(60)
	]
	
	%StudyTree1/TG2EP.text = \
	"\nEach Tachyon Galaxy\ngives a ×%s\nmultiplier to\nEP gained.\n\n" % \
	Globals.float_to_string(1.5, 1)
	
	%StudyTree1/SD2.text = "\nUnlock the %s\nSpace Dimension.\n\n\n" % \
	Globals.ordinal(2)
	
	for i in %StudyTree1.get_children():
		if i is Study:
			i.text += "Cost: %s Space Theorem%s" % [
				Globals.int_to_string(i.cost),
				"" if i.cost == 1 else "s"
			]
	
	%StudyTree2.visible = ("SD2" in purchased)
	
	%StudyTree2/DGIn.text = \
	"\nDuplicantes Galaxies\ndon't reset\nInterval upgrades.\n\n\n"
	
	%StudyTree2/DGCh.text = \
	"\nDuplicantes Galaxies\ndon't reset\nChance upgrades.\n\n\n"
	
	%StudyTree2/EPx.text = \
	"\n\nGain ×%s more\nBoundlessness Points.\n\n\n" % \
	Globals.int_to_string(5)
	
	
	%StudyTree2/Tach1.text = \
	"Dimensional Rewind\naffects all other\n" + \
	"Tachyon Dimensions with\nreduced effect.\n(Currently: ×%s)\n\n" % \
	Formulas.study_tach1()
	
	%StudyTree2/Tach2.text = "\nThe boost from\nTime Dilation gets\n" + \
	"an additional ×%s\nmultiplier.\n\n" % Globals.float_to_string(2)
	
	%StudyTree2/Tach3.text = "Tachyon Dimensions are\nmultiplied by " + \
	"the\ncurrent amount\nof Duplicantes.\n(Currently: ×%s)\n\n" % (
		Globals.Duplicantes.to_string()
		if Globals.Duplicantes.exponent >= 0
		else Globals.float_to_string(1)
	)
	
	
	%StudyTree2/Time1.text = \
	"Dimensional Rewind\naffects the first " + \
	Globals.int_to_string(4) + \
	"\nEternity Dimensions with\ngreatly reduced effect.\n(Currently: ×%s)\n\n" % \
	Globals.float_to_string(Formulas.study_time1())
	
	%StudyTree2/Time2.text = \
	"\nTime Dilation affects\nEternity Dimensions with" + \
	"\nreduced effect.\n(Currently: ×1.24e9999)\n\n"
	
	%StudyTree2/Time3.text = "The Duplicantes\nmultiplier is raised" + \
	"\nto a power based on\nDuplicantes Galaxies.\n(Currently: ^%s)\n\n" % \
	Globals.float_to_string(Formulas.study_time3())
	
	
	%StudyTree2/Space1.text = \
	"Dimensional Rewind\naffects the " + \
	 Globals.ordinal(2) + \
	"\nSpace Dimension with\ngreatly reduced effect.\n(Currently: ×%s)\n\n" % \
	Globals.float_to_string(Formulas.study_space1())
	
	%StudyTree2/Space2.text = \
	"Time Dilation\naffects Space" + \
	"\nDimension with\ngreatly reduced effect.\n(Currently: ×%s.)\n\n" % \
	Globals.float_to_string(Formulas.study_space1())
	
	%StudyTree2/Space3.text = \
	"Dimensional Rewind\naffects the " + \
	 Globals.ordinal(2) + \
	"\nSpace Dimension with\ngreatly reduced effect.\n(Currently: ×%s)\n\n" % \
	Globals.float_to_string(Formulas.study_space1())
	
	
	for i in %StudyTree2.get_children():
		if i is Study:
			i.text += "Cost: %s Space Theorem%s" % [
				Globals.int_to_string(i.cost),
				"" if i.cost == 1 else "s"
			]
	

func respec():
	for id in purchased:
		if find_study(id) != null:
			find_study(id).bought = false
	purchased = []
	ST = largenum.new(TCST + EPST + BPST)

func buy_study(which):
	if which is String:
		which = find_study(which)
	if which is Study:
		if which.cost > ST.to_float():
			return
		ST.add2self(-which.cost)
		purchased.append(which.id_label.text)
		which.bought = true

func find_study(id:String):
	for tree in %Trees.get_children():
		for i in tree.get_children():
			if i is Study:
				if i.id_label.text == id:
					return i
