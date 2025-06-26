extends TabContainer

var text := {
	"Purchases": "\uf201",
	"Timespeed": "\uf017",
	"Time Dilation": "\uf102",
	"Achievements": "\uf091",
	"Dimensional Rewind": "\uf04a",
	"Permanence Upgrades": "δ↑",
	"Overcome Upgrades": "δ⭻",
	"Challenge 2" : "⁈ Ⅱ",
	"Challenge 3" : "⁈ Ⅲ",
	"Challenge 3 (TD3)": "⁈ Ⅲ",
	"Challenge 9" : "⁈ Ⅸ",
	"Challenge 14": "⁈ ⅩⅣ",
	"Base gain from Tachyons": "Ψ→",
	"Permanence Challenge 1 reward" : "Δ⁈ Ⅰ→",
	"Permanence Challenge 3" : "Δ⁈ Ⅲ",
	"Permanence Challenge 6 reward" : "Δ⁈ Ⅵ→",
	"Repeatable ×2 multiplier" : " ×2",
	"Dimension 1" : "⇠1⇢",
	"Dimension 2" : "⇠2⇢",
	"Dimension 3" : "⇠3⇢",
	"Dimension 4" : "⇠4⇢",
	"Dimension 5" : "⇠5⇢",
	"Dimension 6" : "⇠6⇢",
	"Dimension 7" : "⇠7⇢",
	"Dimension 8" : "⇠8⇢",
}
var colors := {
	"Timespeed": Color("#4D5E42"),
	"Achievements": Color("#FDC11B"),
	"Permanence Upgrades": Color("#B341E0"),
	"Overcome Upgrades": Color("#B341E0"),
	"Challenges" : Color("#B03737"),
	"Base gain from Tachyons": Color("#63DD17"),
	"Permanence Challenges": Color("#B341E0"),
}
var groups := [
	"Permanence Upgrades", "Achievements", "Overcome Upgrades"
]

func _process(_delta):
	var active_dimensions = TachyonDims.DimsUnlocked
	for i in range(TachyonDims.DimsUnlocked, 0, -1):
		if TachyonDims.DimPurchase[i-1] == 0:
			active_dimensions -= 1
		else:
			break
	var TachEffects = {}
	match $Tachyons/Mode.button_pressed:
		true:
			for i in active_dimensions:
				var j = TachyonDims.Effects[i]
				var value = largenum.new(1)
				for k in j:
					value.mult2self(j[k].value())
				TachEffects["Dimension %d" % (i+1)] = \
				Currencies.Effect.new(value)
		false:
			for i in active_dimensions:
				var j = TachyonDims.Effects[i]
				for k in j:
					if TachEffects.has(k):
						if TachEffects[k].type == 1:
							TachEffects[k] = Currencies.Effect.new(
								TachEffects[k].value().mult2self(j[k].value()),
								TachEffects[k].type
							)
					else:
						TachEffects[k] = \
						Currencies.Effect.new(j[k].amount, j[k].type)
	
	$Tachyons/Label.text = "Base Tachyon production: " + \
	process_effects(TachEffects, $Tachyons).to_string()
	if $Tachyons/Mode.button_pressed:
		$Tachyons/Mode.text = "Sorting by: Dimensions"
	else:
		$Tachyons/Mode.text = "Sorting by: Multipliers"
	
	if Globals.progress < Globals.Progression.Permanence:
		set_tab_hidden(1, true)
	else:
		set_tab_hidden(1, false)
		$"Permanence Points/Label".text = \
		"Permanence Points gained on Big Bang: " + \
		process_effects(Permanence.PPEffects, $"Permanence Points")\
		.to_string()

func process_effects(Effects, RootNode):
	var Mult = RootNode.get_node("Slices/Mult")
	var Div  = RootNode.get_node("Slices/Div")
	
	var base = largenum.new(1)
	var divs = largenum.new(1)
	var divisor_labels := []
	for i in Effects:
		if Effects[i].value().exponent < 0:
			divs = divs.apply_effect(Effects[i])
			divisor_labels.append(i)
		else:
			base = base.apply_effect(Effects[i])
	divs.pow2self(-1)
	
	for i in Mult.get_children():
		if (not i.name in Effects.keys() or i.name in divisor_labels) \
		and not i.name in ["0", "1"]:
			i.queue_free()
	for i in Div.get_children():
		if (not i.name in Effects.keys() or not i.name in divisor_labels) \
		and not i.name in ["0", "1"]:
			i.queue_free()
	
	var tree_root : TreeItem = RootNode.get_node("Tree").get_root()
	if tree_root == null:
		tree_root = RootNode.get_node("Tree").create_item()
		RootNode.get_node("Tree").set_column_title(0, "Name")
		RootNode.get_node("Tree").set_column_title(1, "Percentage")
		RootNode.get_node("Tree").set_column_title(2, "Multiplier")
		for i in groups:
			var item = tree_root.create_child()
			item.set_text(0, i)
	
	for i in tree_root.get_children():
		i.visible = false
		for j in i.get_children():
			j.visible = false
	
	for key in Effects:
		var slice : ColorRect
		if key in divisor_labels:
			if Div.get_node_or_null(key) == null:
				slice = RootNode.get_node("ColorRect").duplicate()
				Div.add_child(slice)
				slice.name = key
				if text.has(key):
					slice.get_node("Label").text = text[key]
				if colors.has(key):
					slice.color = colors[key]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = Div.get_node(key)
		else:
			if Mult.get_node_or_null(key) == null:
				slice = RootNode.get_node("ColorRect").duplicate()
				Mult.add_child(slice)
				slice.name = key
				if text.has(key):
					slice.get_node("Label").text = text[key]
				else:
					for i in text:
						if key.begins_with(i.trim_suffix("s")):
							slice.get_node("Label").text = text[i]
				if colors.has(key):
					slice.color = colors[key]
				else:
					for i in colors:
						if key.begins_with(i.trim_suffix("s")):
							slice.color = colors[i]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = Mult.get_node(key)
		var mult = Effects[key]
		var item : TreeItem = null
		for i in tree_root.get_children():
			if i.get_text(0) == key:
				item = i
		if item == null:
			for i in tree_root.get_children():
				if key.begins_with(i.get_text(0).trim_suffix("s")):
					for j in i.get_children():
						if j.get_text(0) == key:
							item = j
							break
					if item == null:
						item = RootNode.get_node("Tree").create_item(i)
		if item == null:
			item = RootNode.get_node("Tree").create_item(tree_root)
		item.visible = true
		
		if mult.type == 1:
			slice.size_flags_stretch_ratio = abs(mult.value().log2()) / base.log2()
			item.set_text(0, key)
			item.set_text(1,
				Globals.percent_to_string(mult.value().log2() / base.log2())
			)
			item.set_text(2, mult.display(0))
			if abs(mult.value().log2() / base.log2()) < 1e-5:
				slice.hide()
			else: slice.show()
		if mult.type == 2:
			slice.size_flags_stretch_ratio = mult.value().to_float() - 1
			item.set_text(0, key)
			item.set_text(1,
				Globals.percent_to_string(mult.value().to_float() - 1)
			)
			item.set_text(2, mult.display(0))
		slice.size_flags_stretch_ratio = abs(slice.size_flags_stretch_ratio)
	
	Div.visible = (divs.log2() > 0)
	Mult.get_node("0").visible = base.log2() == 0
	
	if divs.exponent > base.exponent:
		Mult.get_node("1").size_flags_stretch_ratio = \
		abs(divs.log2() / base.log2() - 1)
		Mult.get_node("1").show()
		Div.get_node("0").hide()
	else:
		Div.get_node("0").size_flags_stretch_ratio = \
		abs(divs.log2() / base.log2() - 1)
		Mult.get_node("1").hide()
		Div.get_node("0").show()
	
	for i in tree_root.get_children():
		if i.get_text(0) in groups:
			i.visible = false
			for j in i.get_children():
				if j.visible:
					i.visible = true
			var mult = largenum.new(1)
			var powr = 1
			var percent = 0
			for j in Effects:
				if j.begins_with(i.get_text(0).trim_suffix("s")):
					if Effects[j].type == 1:
						mult.mult2self(Effects[j].value())
					if Effects[j].type == 2:
						powr *= Effects[j].value().to_float()
					if Mult.get_node_or_null("%s" % j) != null:
						percent += Mult.get_node("%s" % j).\
						size_flags_stretch_ratio
					if Div.get_node_or_null("%s" % j) != null:
						percent -= Div.get_node("%s" % j).\
						size_flags_stretch_ratio
			i.set_text(1, Globals.percent_to_string(percent))
			if mult.exponent != 0:
				i.set_text(2, "×%s" % mult.to_string())
				if powr != 1:
					i.set_text(2, "×%s, ^%s" % [
						mult.to_string(), Globals.float_to_string(powr)
					])
			elif powr != 1:
				i.set_text(2, "^%s" % Globals.float_to_string(powr))
	return base.divide(divs)
