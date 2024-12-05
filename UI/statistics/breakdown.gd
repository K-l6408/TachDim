extends TabContainer

var text := {
	"Purchases": "\uf201",
	"Timespeed": "\uf017",
	"Time Dilation" : "\uf102",
	"Achievements" : "\uf091",
}

func _process(delta):
	for i in $Tachyons/Slices.get_children():
		if not i.name in Currencies.Tachyons.mults.keys():
			i.queue_free()
	
	var baseTachyons = largenum.new(1)
	for i in Currencies.Tachyons.mults.values():
		if i is Currencies.Multiplier:
			baseTachyons.mult2self(i.power)
		if i is Dictionary:
			for j in i.values():
				if j is Currencies.Multiplier:
					baseTachyons.mult2self(j.power)
		if i is Array:
			for j in i:
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
			i.show()
			$Tachyons/Slices.add_child(i)
			i.size_flags_horizontal = SIZE_EXPAND_FILL
		match key:
			"Purchases":
				var total = largenum.new(1)
				for i in Currencies.Tachyons.mults[key]:
					total.mult2self(i.power)
				$Tachyons/Slices/Purchases.size_flags_stretch_ratio = \
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
				for i in Currencies.Tachyons.mults[key].size():
					var lower : TreeItem = $Tachyons/Tree.create_item(item)
					lower.set_text(0, "%s: %s (×%s)" % [
						Globals.percent_to_string(
							Currencies.Tachyons.mults[key][i].power.log2() / \
							total.log2()
						), "Purchased TD%s" % Globals.int_to_string(i+1),
						Currencies.Tachyons.mults[key][i].power.to_string()
					])
			"Time Dilation":
				var total = largenum.new(1)
				for i in Currencies.Tachyons.mults[key]:
					total.mult2self(i.power)
				$"Tachyons/Slices/Time Dilation".size_flags_stretch_ratio = \
				total.log2() / baseTachyons.log2()
				var item : TreeItem
				if tree_root.get_child_count() < HOW_MANY:
					item = $Tachyons/Tree.create_item(tree_root)
				else: item = tree_root.get_child(HOW_MANY - 1)
				item.set_text(0, "%s: %s (×%s)" % [
					Globals.percent_to_string(total.log2() / baseTachyons.log2()),
					key, total.to_string()
				])
