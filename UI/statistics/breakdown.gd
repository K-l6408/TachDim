extends TabContainer

var text := {
	"Purchases": "\uf201",
	"Timespeed": "\uf017",
	"Time Dilation": "\uf102",
	"Achievements": "\uf091",
	"Dimensional Rewind": "\uf04a",
	"Eternity Upgrades": "Δ↑",
	"Overcome Eternity Upgrades": "Δ⭻",
	"Space Studies": "\uf0e8",
}
var colors := {
	"Timespeed": Color("#4D5E42"),
	"Achievements": Color("#FDC11B"),
	"Eternity Upgrades": Color("#B341E0"),
	"Overcome Eternity Upgrades": Color("#B341E0"),
}

func _process(delta):
	for i in $Tachyons/Slices.get_children():
		if not i.name in Currencies.Tachyons.mults.keys():
			i.queue_free()
	
	var active_dimensions = TachyonDims.DimsUnlocked
	for i in range(TachyonDims.DimsUnlocked, 0, -1):
		if TachyonDims.DimPurchase[i-1] == 0:
			active_dimensions -= 1
		else:
			break
	
	var baseTachyons = largenum.new(1)
	for i in Currencies.Tachyons.mults.values():
		if i is Currencies.Multiplier:
			baseTachyons.mult2self(i.power.power(min(i.dims, active_dimensions)))
		if i is Dictionary:
			for j in i.values():
				if j is Currencies.Multiplier:
					baseTachyons.mult2self(j.power)
		if i is Array:
			var k = 0
			for j in i:
				k += 1
				if k > active_dimensions: break
				if j is Currencies.Multiplier:
					baseTachyons.mult2self(j.power)
	
	$Tachyons/Label.text = "Base Tachyon production: %s" % baseTachyons.to_string()
	
	var tree_root : TreeItem = $Tachyons/Tree.get_root()
	if tree_root == null:
		tree_root = $Tachyons/Tree.create_item()
	
	var HOW_MANY = 0
	
	for key in Currencies.Tachyons.mults:
		HOW_MANY += 1
		if $Tachyons/Slices.get_node_or_null(key) == null:
			var i :ColorRect= $Tachyons/ColorRect.duplicate()
			i.name = key
			if text.has(key):
				i.get_node("Label").text = text[key]
			if colors.has(key):
				i.color = colors[key]
			i.show()
			$Tachyons/Slices.add_child(i)
			i.size_flags_horizontal = SIZE_EXPAND_FILL
		var slice = $Tachyons/Slices.get_node(key)
		var mult = Currencies.Tachyons.mults[key]
		match key:
			"Purchases":
				var total = largenum.new(1)
				for i in mult:
					total.mult2self(i.power)
				slice.size_flags_stretch_ratio = \
				total.log2() / baseTachyons.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $Tachyons/Tree.create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(total.log2() / baseTachyons.log2()).\
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
				elif abs(baseTachyons.log2() / total.log2()) > 1e5:
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
				total.log2() / baseTachyons.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $Tachyons/Tree.create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(total.log2() / baseTachyons.log2()),
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
				elif abs(baseTachyons.log2() / total.log2()) > 1e5:
					slice.hide()
				else:
					slice.show()
					item.visible = true
			_:
				if mult is Currencies.Multiplier:
					if not mult.is_power:
						slice.size_flags_stretch_ratio = \
						mult.power.power(min(mult.dims, active_dimensions)).log2() \
						/ baseTachyons.log2()
						var item : TreeItem
						if tree_root.get_child_count() < HOW_MANY:
							item = $Tachyons/Tree.create_item(tree_root)
						else: item = tree_root.get_child(HOW_MANY - 1)
						if mult.dims > 1:
							item.set_text(0, "%s: %s (×%s on %s Dimension%s → ×%s)" % [
								Globals.percent_to_string(
									mult.power.log2() / baseTachyons.log2()\
									 * min(mult.dims, active_dimensions)
								), key, mult.power.to_string(),
								Globals.int_to_string(min(mult.dims, active_dimensions)),
								"" if min(mult.dims, active_dimensions) == 1 else "s",
								mult.power.power(min(mult.dims, active_dimensions)).to_string()
							])
						else:
							item.set_text(0, "%s: %s (×%s)" % [
								Globals.percent_to_string(
									mult.power.log2() / baseTachyons.log2()\
									 * min(mult.dims, active_dimensions)
								), key, mult.power.to_string()
							])
						if mult.power.log2() == 0:
							slice.hide()
							item.visible = false
						elif abs(
							baseTachyons.log2() / mult.power.power(mult.dims).log2()
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
					total.log2() / baseTachyons.log2()
					
					var item : TreeItem
					if tree_root.get_child_count() < HOW_MANY:
						item = $Tachyons/Tree.create_item(tree_root)
					else: item = tree_root.get_child(HOW_MANY - 1)
					
					item.set_text(0, "%s: %s (×%s)" % [
						Globals.percent_to_string(total.log2() / baseTachyons.log2()),
						key, total.to_string()
					])
					
					for i in item.get_children():
						i.free()
					for i in mult:
						if mult[i].power.log2() == 0:
							continue
						var lower : TreeItem = $Tachyons/Tree.create_item(item)
						if min(mult[i].dims, active_dimensions) > 1:
							lower.set_text(0, "%s: %s (×%s on %s Dimensions → %s)" % [
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
					elif abs(baseTachyons.log2() / total.log2()) > 1e5:
						slice.hide()
					else:
						slice.show()
						item.visible = true
				if mult == null:
					if tree_root.get_child_count() >= HOW_MANY:
						tree_root.get_child(HOW_MANY - 1).visible = false
					slice.hide()
