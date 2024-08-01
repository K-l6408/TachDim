extends Control

const ANIMATION = [
	"Big Bang"
]

func save_anim_settings():
	var mask = 1
	var current = 0
	for i in %AnimOptions.get_children():
		if not i is CheckButton: continue
		if i.button_pressed: current += mask
		mask >>= 1
	return current

func load_anim_settings(current : int):
	var mask = 1
	for i in %AnimOptions.get_children():
		if not i is CheckButton: continue
		i.button_pressed = current & mask
		mask >>= 1

func _ready():
	for i in GL.DisplayMode.keys():
		$HFlow/Notation.add_item(i.replace("_", " "))
	for i in ANIMATION.size():
		var C = ANIMATION[i]
		var ck = $Check.duplicate()
		ck.name = C
		ck.text = C
		ck.connect("toggled", change_anim_opt.bind(i))
		%AnimOptions.add_child(ck)

func change_anim_opt(what, index):
	Globals.AnimOpt[index] = what

func change_notation(index):
	Globals.display = index as GL.DisplayMode

func _process(_delta):
	for i in ANIMATION.size():
		var j = false
		match i:
			0: j = (Globals.progress >= Globals.Progression.Eternity)
		%AnimOptions.get_node(ANIMATION[i]).visible = j
	$HFlow/Notation.select(Globals.display)
	$HFlow/Scaling/Label.text = " \nUI Scaling: ×%.2f" % $HFlow/Scaling.value

func change_ui_scaling(value_changed):
	get_node("/root").content_scale_factor = $HFlow/Scaling.value
