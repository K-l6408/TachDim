extends Control

const ANIMATION = [
	"Big Bang"
]
const THEMES = {
	"Dark" : preload("res://themes/Dark.tres"),
	"Light": preload("res://themes/Light.tres"),
	"Blob" : preload("res://themes/Blob.tres"),
}
var theme_txt = "Dark"

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
		$HFlow/Notation.add_item("Notation: " + i.replace("_", " "))
	for key in THEMES:
		$HFlow/Theme.add_item("Theme: " + key)
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
	$HFlow/Scaling/Label.text = "UI Scaling: ×%s" % \
	Globals.float_to_string($HFlow/Scaling.value)
	%AnimOptions/Blobs.visible = (theme_txt == "Blob")
	custom_minimum_size.y = $HFlow.size.y
	if Input.is_action_just_pressed("Zoom+") and $HFlow/Scaling.value < 4:
		$HFlow/Scaling.value *= (2 ** +(1. / 3))
		change_ui_scaling()
	if Input.is_action_just_pressed("Zoom-") and $HFlow/Scaling.value > 0.25:
		$HFlow/Scaling.value *= (2 ** -(1. / 3))
		change_ui_scaling()

func change_ui_scaling(_value_changed = false):
	get_node("/root").content_scale_factor = $HFlow/Scaling.value

func change_theme(index):
	if index is int:
		theme_txt = $HFlow/Theme.get_item_text(index).trim_prefix("Theme: ")
	if index is String:
		theme_txt = index
		$HFlow/Theme.selected = THEMES.keys().find(index)
	if not THEMES.has(theme_txt):
		theme_txt = "Dark"
	emit_signal("theme_change", THEMES[theme_txt])

signal theme_change(which : Theme)
