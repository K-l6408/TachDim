extends Control

const MAXROWS = 20
var loaded_rows = 2
var unlocked : PackedByteArray = []
var achgot : int :
	get:
		var a = 0
		for R in min(MAXROWS, loaded_rows):
			for C in range(1, 9):
				if is_unlocked(R+1, C): a += 1
		return a

func achnames(r, c):
	match r:
		1: match c:
			1: return "Welcome to TachDim!"
			2: return "%s already‽" % Globals.int_to_string(100)
			3: return "Rule of threes or something"
			4: return "ouugbhh"
			5: return "Just a handful"
			6: return "More like SEXTH DIMENSION"
			7: return "No RNG required"
			8: return "Seven %s Nine" % Globals.int_to_string(8).to_pascal_case()
		2: match c:
			1: return "Tier %s-C" % Globals.int_to_string(3)
			2: return "Galaxy %s: the sequel" % Globals.int_to_string(2)
			8: return "Popular TV sitcom"
	return "TBD"

func achreqs(r, c):
	match r:
		1: return "Buy a %s Tachyon Dimension" % Globals.ordinal(c)
		2: match c:
			1: return "Get a Tachyon Galaxy."
			2: return "Get ANOTHER Tachyon Galaxy."
			8: return "Reach Infinite Tachyons.\n(Reward: Start with %s Tachyons.)" % Globals.int_to_string(100)
	return "TBD"

func is_unlocked(row, num):
	return unlocked[row-1] & (2 ** (num - 1))

func set_unlocked(row, num, val := true):
	if val:
		unlocked[row-1] |= (2 ** (num - 1))
		Globals.notificate(
			"achievement",
			"Achievement unlocked: \"%s\"" % achnames(row, num)
		)
	else:
		unlocked[row-1] &= 255 - (2 ** (num - 1))

func _ready():
	unlocked.resize(MAXROWS)
	unlocked.fill(0)
	for i in min(MAXROWS, loaded_rows):
		for j in 8:
			var n : TextureRect = $Achiev.duplicate()
			n.texture = n.texture.duplicate()
			n.texture.region.position = n.texture.region.size * Vector2(j, i)
			n.name = "%d%d" % [i+1, j+1]
			%GridContainer.add_child(n)
			n.get_node("Label").text = n.name
			n.show()

func _process(delta):
	for i in range(1, min(MAXROWS, %GridContainer.get_child_count() / 8) + 1):
		for j in range(1, 9):
			%GridContainer.get_node("%d%d" % [i,j]).self_modulate = \
			Color("9f9") if is_unlocked(i,j) else Color("999")
			%GridContainer.get_node("%d%d" % [i,j]).tooltip_text = \
			"\"%s\"\n%s" % [achnames(i,j), achreqs(i,j)]
	for i in 8:
		if not is_unlocked(1,i+1):
			if Globals.TDHandler.DimPurchase[i] > 0:
				set_unlocked(1,i+1)
	if not is_unlocked(2, 1):
		if Globals.TGalaxies >= 1:
			set_unlocked(2, 1)
	if not is_unlocked(2, 2):
		if Globals.TGalaxies >= 2:
			set_unlocked(2, 2)
	if not is_unlocked(2, 8):
		if Globals.progress >= Globals.Progression.Eternity:
			set_unlocked(2, 8)
