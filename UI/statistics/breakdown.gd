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
	process_tachyon_mults()
	if $Tachyons/Mode.button_pressed:
		$Tachyons/Mode.text = "Sorting by: Dimensions"
	else:
		$Tachyons/Mode.text = "Sorting by: Multipliers"
	#if Permanence.process_pp_gain().exponent < 0:
		#set_tab_hidden(1, true)
	#else:
		#set_tab_hidden(1, false)
		#process_pp_mults()

func process_tachyon_mults():
	var active_dimensions = TachyonDims.DimsUnlocked
	for i in range(TachyonDims.DimsUnlocked, 0, -1):
		if TachyonDims.DimPurchase[i-1] == 0:
			active_dimensions -= 1
		else:
			break
	
	var Effects = {}
	
	match $Tachyons/Mode.button_pressed:
		true:
			for i in active_dimensions:
				var j = TachyonDims.Effects[i]
				var value = largenum.new(1)
				for k in j:
					value.mult2self(j[k].value())
				Effects["Dimension %d" % (i+1)] = \
				Currencies.Effect.new(value)
		false:
			for i in active_dimensions:
				var j = TachyonDims.Effects[i]
				for k in j:
					if Effects.has(k):
						if Effects[k].type == 1:
							Effects[k] = Currencies.Effect.new(
								Effects[k].value().mult2self(j[k].value()),
								Effects[k].type
							)
					else:
						Effects[k] = \
						Currencies.Effect.new(j[k].amount, j[k].type)
	
	for i in $Tachyons/Slices/Mult.get_children():
		if not i.name in Effects.keys() \
		and not i.name in ["0", "1"]:
			i.queue_free()
	for i in $Tachyons/Slices/Div.get_children():
		if not i.name in Effects.keys() \
		and not i.name in ["0", "1"]:
			i.queue_free()
	
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
	
	$Tachyons/Label.text = "Base Tachyon production: %s" % \
	base.divide(divs).to_string()
	
	var tree_root : TreeItem = $Tachyons/Tree.get_root()
	if tree_root == null:
		tree_root = $Tachyons/Tree.create_item()
		for i in groups:
			var item = tree_root.create_child()
			item.set_text(0, i)
	
	for i in tree_root.get_children():
		i.visible = false
		for j in i.get_children():
			j.visible = false
	
	var HOW_MANY = 0
	
	for key in Effects:
		HOW_MANY += 1
		var slice : ColorRect
		if key in divisor_labels:
			if $Tachyons/Slices/Div.get_node_or_null(key) == null:
				slice = $Tachyons/ColorRect.duplicate()
				$Tachyons/Slices/Div.add_child(slice)
				slice.name = key
				if text.has(key):
					slice.get_node("Label").text = text[key]
				if colors.has(key):
					slice.color = colors[key]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = $Tachyons/Slices/Div.get_node(key)
		else:
			if $Tachyons/Slices/Mult.get_node_or_null(key) == null:
				slice = $Tachyons/ColorRect.duplicate()
				$Tachyons/Slices/Mult.add_child(slice)
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
				slice = $Tachyons/Slices/Mult.get_node(key)
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
						item = $Tachyons/Tree.create_item(i)
		if item == null:
			item = $Tachyons/Tree.create_item(tree_root)
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
	
	$Tachyons/Slices/Div.visible = (divs.log2() > 0)
	$"Tachyons/Slices/Mult/0".visible = base.log2() == 0
	
	if divs.exponent > base.exponent:
		$"Tachyons/Slices/Mult/1".size_flags_stretch_ratio = \
		abs(divs.log2() / base.log2() - 1)
		$"Tachyons/Slices/Mult/1".show()
		$"Tachyons/Slices/Div/0".hide()
	else:
		$"Tachyons/Slices/Div/0".size_flags_stretch_ratio = \
		abs(divs.log2() / base.log2() - 1)
		$"Tachyons/Slices/Mult/1".hide()
		$"Tachyons/Slices/Div/0".show()
	
	for i in tree_root.get_children():
		if i.get_text(0) in groups:
			i.visible = false
			for j in i.get_children():
				if j.visible:
					i.visible = true
			var mult = largenum.new(1)
			var pow = 1
			var percent = 0
			for j in Effects:
				if j.begins_with(i.get_text(0).trim_suffix("s")):
					if Effects[j].type == 1:
						mult.mult2self(Effects[j].value())
					if Effects[j].type == 2:
						pow *= Effects[j].value().to_float()
					if get_node_or_null("Tachyons/Slices/Mult/%s" % j) != null:
						percent += get_node("Tachyons/Slices/Mult/%s" % j).\
						size_flags_stretch_ratio
					if get_node_or_null("Tachyons/Slices/Div/%s" % j) != null:
						percent -= get_node("Tachyons/Slices/Div/%s" % j).\
						size_flags_stretch_ratio
			i.set_text(1, Globals.percent_to_string(percent))
			if mult.exponent != 0:
				i.set_text(2, "×%s" % mult.to_string())
				if pow != 1:
					i.set_text(2, "×%s, ^%s" % [
						mult.to_string(), Globals.float_to_string(pow)
					])
			elif pow != 1:
				i.set_text(2, "^%s" % Globals.float_to_string(pow))

#func process_pp_mults():
	#for i in $"Permanence Points/Slices/Mult".get_children():
		#if not i.name in Currencies.PermanencePts.mults.keys() \
		#and not i.name in ["0", "1"]:
			#i.queue_free()
	#
	#var base = largenum.new(1)
	#var divs = largenum.new(1)
	#for i in Currencies.PermanencePts.mults.values():
		#if i is Currencies.Multiplier:
			#if i.power.exponent < 0:
				#divs.mult2self(i.power.power(-1))
			#else:
				#base.mult2self(i.power.power(1))
		#if i is Dictionary:
			#for j in i.values():
				#if j is Currencies.Multiplier:
					#if j.power.exponent < 0:
						#divs.mult2self(j.power.power(-1))
					#else:
						#base.mult2self(j.power)
		#if i is Array:
			##var k = 0
			#for j in i:
				##k += 1
				#if j is Currencies.Multiplier:
					#if j.power.exponent < 0:
						#divs.mult2self(j.power.power(-1))
					#else:
						#base.mult2self(j.power)
	#
	#$"Permanence Points/Label".text = "Permanence Points gained on prestige: %s" % \
	#base.divide(divs).to_string()
	#
	##if base.exponent < 0: base.pow2self(-1)
	#
	#var tree_root : TreeItem = $"Permanence Points/Tree".get_root()
	#if tree_root == null:
		#tree_root = $"Permanence Points/Tree".create_item()
	#
	#var HOW_MANY = 0
	#
	#for key in Currencies.PermanencePts.mults:
		#HOW_MANY += 1
		#var slice : ColorRect
		#if key in divisors:
			#if $"Permanence Points/Slices/Div".get_node_or_null(key) == null:
				#slice = $"Permanence Points/ColorRect".duplicate()
				#$"Permanence Points/Slices/Div".add_child(slice)
				#slice.name = key
				#if text.has(key):
					#slice.get_node("Label").text = text[key]
				#if colors.has(key):
					#slice.color = colors[key]
				#slice.show()
				#slice.size_flags_horizontal = SIZE_EXPAND_FILL
			#else:
				#slice = $"Permanence Points/Slices/Div".get_node(key)
		#else:
			#if $"Permanence Points/Slices/Mult".get_node_or_null(key) == null:
				#slice = $"Permanence Points/ColorRect".duplicate()
				#$"Permanence Points/Slices/Mult".add_child(slice)
				#slice.name = key
				#if text.has(key):
					#slice.get_node("Label").text = text[key]
				#if colors.has(key):
					#slice.color = colors[key]
				#slice.show()
				#slice.size_flags_horizontal = SIZE_EXPAND_FILL
			#else:
				#slice = $"Permanence Points/Slices/Mult".get_node(key)
		#var mult = Currencies.PermanencePts.mults[key]
		##match key:
			##_:
		#if mult is Currencies.Multiplier:
			#slice.size_flags_stretch_ratio = \
			#mult.power.log2() \
			#/ base.log2()
			#var item : TreeItem
			#if tree_root.get_child_count() < HOW_MANY:
				#item = $"Permanence Points/Tree".create_item(tree_root)
			#else: item = tree_root.get_child(HOW_MANY - 1)
			#
			#if mult.force_power == 0:
				#item.set_text(0, "%s: %s (×%s)" % [
					#Globals.percent_to_string(
						#mult.power.log2() / base.log2()
					#), key, mult.power.to_string()
				#])
			#else:
				#item.set_text(0, "%s: %s (^%s)" % [
					#Globals.percent_to_string(
						#mult.power.log2() / base.log2()
					#), key, Globals.float_to_string(mult.force_power)
				#])
			#if mult.power.log2() == 0:
				#slice.hide()
				#item.visible = false
			#elif abs(
				#base.log2() / mult.power.power(mult.dims).log2()
			#) > 1e5:
				#slice.hide()
			#else:
				#slice.show()
				#item.visible = true
		#if mult is Dictionary:
			#var total = largenum.new(1)
			#for i in mult:
				#total.mult2self(mult[i].power)
			#slice.size_flags_stretch_ratio = \
			#total.log2() / base.log2()
			#
			#var item : TreeItem
			#if tree_root.get_child_count() < HOW_MANY:
				#item = $"Permanence Points/Tree".create_item(tree_root)
			#else: item = tree_root.get_child(HOW_MANY - 1)
			#
			#item.set_text(0, "%s: %s (×%s)" % [
				#Globals.percent_to_string(total.log2() / base.log2()),
				#key, total.to_string()
			#])
			#
			#for i in item.get_children():
				#i.free()
			#for i in mult:
				#if mult[i].power.log2() == 0:
					#continue
				#var lower : TreeItem = $"Permanence Points/Tree".create_item(item)
				#lower.set_text(0, "%s: %s (×%s)" % [
					#Globals.percent_to_string(
						#mult[i].power.log2() / \
						#total.log2()
					#), i,
					#mult[i].power.to_string()
				#])
			#
			#if total.log2() == 0:
				#slice.hide()
				#item.visible = false
			#elif abs(base.log2() / total.log2()) > 1e5:
				#slice.hide()
			#else:
				#slice.show()
				#item.visible = true
		#if mult == null:
			#if tree_root.get_child_count() >= HOW_MANY:
				#tree_root.get_child(HOW_MANY - 1).visible = false
