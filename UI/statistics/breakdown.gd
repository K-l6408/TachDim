extends TabContainer

var divisors := [
	"Challenge 2", "Challenge 3",
	"Challenge 9", "Challenge 14",
	"Permanence Challenge 3",
]
var text := {
	"Purchases": "\uf201",
	"Timespeed": "\uf017",
	"Time Dilation": "\uf102",
	"Achievements": "\uf091",
	"Dimensional Rewind": "\uf04a",
	"Permanence Upgrades": "δ↑",
	"Overcome Time Upgrades": "δ⭻",
	"Space Studies": "\uf0e8",
	"Challenge 2" : "⁈ Ⅱ",
	"Challenge 3" : "⁈ Ⅲ",
	"Challenge 3 (TD3)": "⁈ Ⅲ",
	"Challenge 9" : "⁈ Ⅸ",
	"Challenge 14": "⁈ ⅩⅣ",
	"Base gain from Tachyons": "Ψ→",
}
var colors := {
	"Timespeed": Color("#4D5E42"),
	"Achievements": Color("#FDC11B"),
	"Permanence Upgrades": Color("#B341E0"),
	"Overcome Time Upgrades": Color("#B341E0"),
	"Challenge 2" : Color("#B03737"),
	"Challenge 3" : Color("#B03737"),
	"Challenge 3 (TD3)": Color("#B03737"),
	"Challenge 9" : Color("#B03737"),
	"Challenge 14": Color("#B03737"),
	"Base gain from Tachyons": Color("#63DD17"),
}

func _process(_delta):
	process_tachyon_mults()
	if Permanence.process_pp_gain().exponent < 0:
		set_tab_hidden(1, true)
	else:
		set_tab_hidden(1, false)
		process_pp_mults()

func process_tachyon_mults():
	for i in $Tachyons/Slices/Mult.get_children():
		if not i.name in Currencies.Tachyons.mults.keys() \
		and not i.name in ["0", "1"]:
			i.queue_free()
	
	var active_dimensions = TachyonDims.DimsUnlocked
	for i in range(TachyonDims.DimsUnlocked, 0, -1):
		if TachyonDims.DimPurchase[i-1] == 0:
			active_dimensions -= 1
		else:
			break
	
	var base = largenum.new(1)
	var divs = largenum.new(1)
	for i in Currencies.Tachyons.mults.values():
		if i is Currencies.Multiplier:
			if i.power.exponent < 0:
				divs.mult2self(i.power.power(min(i.dims, -active_dimensions)))
			else:
				base.mult2self(i.power.power(min(i.dims, active_dimensions)))
		if i is Dictionary:
			for j in i.values():
				if j is Currencies.Multiplier:
					if j.power.exponent < 0:
						divs.mult2self(j.power.power(-1))
					else:
						base.mult2self(j.power)
		if i is Array:
			var k = 0
			for j in i:
				k += 1
				if k > active_dimensions: break
				if j is Currencies.Multiplier:
					if j.power.exponent < 0:
						divs.mult2self(j.power.power(-1))
					else:
						base.mult2self(j.power)
	
	$Tachyons/Label.text = "Base Tachyon production: %s" % \
	base.divide(divs).to_string()
	
	if base.exponent < 0: base.pow2self(-1)
	
	var tree_root : TreeItem = $Tachyons/Tree.get_root()
	if tree_root == null:
		tree_root = $Tachyons/Tree.create_item()
	
	var HOW_MANY = 0
	
	for key in Currencies.Tachyons.mults:
		HOW_MANY += 1
		var slice : ColorRect
		if key in divisors:
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
				if colors.has(key):
					slice.color = colors[key]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = $Tachyons/Slices/Mult.get_node(key)
		var mult = Currencies.Tachyons.mults[key]
		match key:
			"Purchases":
				var total = largenum.new(1)
				for i in mult:
					total.mult2self(i.power)
				slice.size_flags_stretch_ratio = \
				total.log2() / base.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $Tachyons/Tree.create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(total.log2() / base.log2()).\
					replace("nan", "100"),
					key, total.to_string()
				])
				for i in item.get_children():
					i.free()
				for i in mult.size():
					if mult[i].power.log2() == 0:
						continue
					var lower : TreeItem = $Tachyons/Tree.create_item(item)
					lower.set_text(0, "%s: %s (×%s)" % [
						Globals.percent_to_string(
							mult[i].power.log2() / \
							total.log2()
						), "Purchased TD%s" % Globals.int_to_string(i+1),
						mult[i].power.to_string()
					])
				
				if total.log2() == 0:
					slice.hide()
					item.visible = false
				elif abs(base.log2() / total.log2()) > 1e5:
					slice.hide()
				else:
					slice.show()
					item.visible = true
			"Time Dilation":
				var total = largenum.new(1)
				var k = 0
				for i in mult:
					k += 1
					if k > active_dimensions: break
					total.mult2self(i.power)
				slice.size_flags_stretch_ratio = \
				total.log2() / base.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $Tachyons/Tree.create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(total.log2() / base.log2()),
					key, total.to_string()
				])
				
				for i in item.get_children():
					i.free()
				for i in mult.size():
					if i >= active_dimensions: break
					if mult[i].power.log2() == 0:
						continue
					var lower : TreeItem = $Tachyons/Tree.create_item(item)
					lower.set_text(0, "%s: %s (×%s)" % [
						Globals.percent_to_string(
							mult[i].power.log2() / \
							total.log2()
						), "Time Dilation effect on TD%s" % Globals.int_to_string(i+1),
						mult[i].power.to_string()
					])
				
				if total.log2() == 0:
					slice.hide()
					item.visible = false
				elif abs(base.log2() / total.log2()) > 1e5:
					slice.hide()
				else:
					slice.show()
					item.visible = true
			_:
				if mult is Currencies.Multiplier:
					if not mult.is_power:
						slice.size_flags_stretch_ratio = \
						mult.power.power(min(mult.dims, active_dimensions)).log2() \
						/ base.log2()
						var item : TreeItem
						if tree_root.get_child_count() < HOW_MANY:
							item = $Tachyons/Tree.create_item(tree_root)
						else: item = tree_root.get_child(HOW_MANY - 1)
						if mult.dims > 1:
							if key in divisors:
								item.set_text(0, "%s: %s (/%s on %s Dimension%s → /%s)" % [
									Globals.percent_to_string(
										mult.power.log2() / base.log2()\
										 * min(mult.dims, active_dimensions)
									), key, mult.power.power(-1).to_string(),
									Globals.int_to_string(min(mult.dims, active_dimensions)),
									"" if min(mult.dims, active_dimensions) == 1 else "s",
									mult.power.power(-min(mult.dims, active_dimensions)).to_string()
								])
							else:
								item.set_text(0, "%s: %s (×%s on %s Dimension%s → ×%s)" % [
									Globals.percent_to_string(
										mult.power.log2() / base.log2()\
										 * min(mult.dims, active_dimensions)
									), key, mult.power.to_string(),
									Globals.int_to_string(min(mult.dims, active_dimensions)),
									"" if min(mult.dims, active_dimensions) == 1 else "s",
									mult.power.power(min(mult.dims, active_dimensions)).to_string()
								])
						else:
							item.set_text(0, "%s: %s (×%s)" % [
								Globals.percent_to_string(
									mult.power.log2() / base.log2()\
									 * min(mult.dims, active_dimensions)
								), key, mult.power.to_string()
							])
						if mult.power.log2() == 0:
							slice.hide()
							item.visible = false
						elif abs(
							base.log2() / mult.power.power(mult.dims).log2()
						) > 1e5:
							slice.hide()
						else:
							slice.show()
							item.visible = true
				if mult is Dictionary:
					var total = largenum.new(1)
					for i in mult:
						total.mult2self(mult[i].power.power(min(mult[i].dims, active_dimensions)))
					slice.size_flags_stretch_ratio = \
					total.log2() / base.log2()
					
					var item : TreeItem
					if tree_root.get_child_count() < HOW_MANY:
						item = $Tachyons/Tree.create_item(tree_root)
					else: item = tree_root.get_child(HOW_MANY - 1)
					
					item.set_text(0, "%s: %s (×%s)" % [
						Globals.percent_to_string(total.log2() / base.log2()),
						key, total.to_string()
					])
					
					for i in item.get_children():
						i.free()
					for i in mult:
						if mult[i].power.log2() == 0:
							continue
						var lower : TreeItem = $Tachyons/Tree.create_item(item)
						if min(mult[i].dims, active_dimensions) > 1:
							lower.set_text(0, "%s: %s (×%s on %s Dimensions → ×%s)" % [
								Globals.percent_to_string(
									mult[i].power.power(
										min(mult[i].dims, active_dimensions)
									).log2() / \
									total.log2()
								), i,
								mult[i].power.to_string(),
								Globals.int_to_string(min(mult[i].dims, active_dimensions)),
								mult[i].power.power(
									min(mult[i].dims, active_dimensions)
								).to_string()
							])
						else:
							lower.set_text(0, "%s: %s (×%s)" % [
								Globals.percent_to_string(
									mult[i].power.log2() / \
									total.log2()
								), i,
								mult[i].power.to_string()
							])
					
					if total.log2() == 0:
						slice.hide()
						item.visible = false
					elif abs(base.log2() / total.log2()) > 1e5:
						slice.hide()
					else:
						slice.show()
						item.visible = true
				if mult == null:
					if tree_root.get_child_count() >= HOW_MANY:
						tree_root.get_child(HOW_MANY - 1).visible = false
					slice.hide()
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

func process_pp_mults():
	for i in $"Permanence Points/Slices/Mult".get_children():
		if not i.name in Currencies.PermanencePts.mults.keys() \
		and not i.name in ["0", "1"]:
			i.queue_free()
	
	var base = largenum.new(1)
	var divs = largenum.new(1)
	for i in Currencies.PermanencePts.mults.values():
		if i is Currencies.Multiplier:
			if i.power.exponent < 0:
				divs.mult2self(i.power.power(-1))
			else:
				base.mult2self(i.power.power(1))
		if i is Dictionary:
			for j in i.values():
				if j is Currencies.Multiplier:
					if j.power.exponent < 0:
						divs.mult2self(j.power.power(-1))
					else:
						base.mult2self(j.power)
		if i is Array:
			var k = 0
			for j in i:
				k += 1
				if j is Currencies.Multiplier:
					if j.power.exponent < 0:
						divs.mult2self(j.power.power(-1))
					else:
						base.mult2self(j.power)
	
	$"Permanence Points/Label".text = "Permanence Points gained on prestige: %s" % \
	base.divide(divs).to_string()
	
	#if base.exponent < 0: base.pow2self(-1)
	
	var tree_root : TreeItem = $"Permanence Points/Tree".get_root()
	if tree_root == null:
		tree_root = $"Permanence Points/Tree".create_item()
	
	var HOW_MANY = 0
	
	for key in Currencies.PermanencePts.mults:
		HOW_MANY += 1
		var slice : ColorRect
		if key in divisors:
			if $"Permanence Points/Slices/Div".get_node_or_null(key) == null:
				slice = $"Permanence Points/ColorRect".duplicate()
				$"Permanence Points/Slices/Div".add_child(slice)
				slice.name = key
				if text.has(key):
					slice.get_node("Label").text = text[key]
				if colors.has(key):
					slice.color = colors[key]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = $"Permanence Points/Slices/Div".get_node(key)
		else:
			if $"Permanence Points/Slices/Mult".get_node_or_null(key) == null:
				slice = $"Permanence Points/ColorRect".duplicate()
				$"Permanence Points/Slices/Mult".add_child(slice)
				slice.name = key
				if text.has(key):
					slice.get_node("Label").text = text[key]
				if colors.has(key):
					slice.color = colors[key]
				slice.show()
				slice.size_flags_horizontal = SIZE_EXPAND_FILL
			else:
				slice = $"Permanence Points/Slices/Mult".get_node(key)
		var mult = Currencies.PermanencePts.mults[key]
		#match key:
			#_:
		if mult is Currencies.Multiplier:
			if not mult.is_power:
				slice.size_flags_stretch_ratio = \
				mult.power.log2() \
				/ base.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $"Permanence Points/Tree".create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(
						mult.power.log2() / base.log2()
					), key, mult.power.to_string()
				])
				if mult.power.log2() == 0:
					slice.hide()
					item.visible = false
				elif abs(
					base.log2() / mult.power.power(mult.dims).log2()
				) > 1e5:
					slice.hide()
				else:
					slice.show()
					item.visible = true
		if mult is Dictionary:
			var total = largenum.new(1)
			for i in mult:
				total.mult2self(mult[i].power)
			slice.size_flags_stretch_ratio = \
			total.log2() / base.log2()
			
			var item : TreeItem
			if tree_root.get_child_count() < HOW_MANY:
				item = $"Permanence Points/Tree".create_item(tree_root)
			else: item = tree_root.get_child(HOW_MANY - 1)
			
			item.set_text(0, "%s: %s (×%s)" % [
				Globals.percent_to_string(total.log2() / base.log2()),
				key, total.to_string()
			])
			
			for i in item.get_children():
				i.free()
			for i in mult:
				if mult[i].power.log2() == 0:
					continue
				var lower : TreeItem = $"Permanence Points/Tree".create_item(item)
				lower.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(
						mult[i].power.log2() / \
						total.log2()
					), i,
					mult[i].power.to_string()
				])
			
			if total.log2() == 0:
				slice.hide()
				item.visible = false
			elif abs(base.log2() / total.log2()) > 1e5:
				slice.hide()
			else:
				slice.show()
				item.visible = true
		if mult == null:
			if tree_root.get_child_count() >= HOW_MANY:
				tree_root.get_child(HOW_MANY - 1).visible = false
			slice.hide()
		slice.size_flags_stretch_ratio = abs(slice.size_flags_stretch_ratio)
	
	$"Permanence Points/Slices/Div".visible = (divs.log2() > 0)
	$"Permanence Points/Slices/Mult/0".visible = base.log2() == 0
	
	if divs.exponent > base.exponent:
		$"Permanence Points/Slices/Mult/1".size_flags_stretch_ratio = \
		abs(divs.log2() / base.log2())
		$"Permanence Points/Slices/Mult/1".show()
		$"Permanence Points/Slices/Div/0".hide()
	else:
		$"Permanence Points/Slices/Div/0".size_flags_stretch_ratio = 1
		$"Permanence Points/Slices/Mult/1".hide()
		$"Permanence Points/Slices/Div/0".show()
