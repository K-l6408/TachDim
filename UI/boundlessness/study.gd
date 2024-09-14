@tool
extends Button
class_name Study

@export var row = 0 :
	set(value):
		row = value
		update_label()
		if get_parent() is StudyTreeContainer:
			get_parent().sort()
var column = 1 :
	set(value):
		column = value
		update_label()
@export var id_override = "" :
	set(value):
		id_override = value
		update_label()
@export var studies_required : Array[Study] = [] :
	set(value):
		studies_required = value
		if get_parent() is StudyTreeContainer:
			get_parent().sort()
@export var needs_all_studies = false
@export var linked_to : Study = null
@export var cost := 0
@export var line_color = Color.DIM_GRAY :
	set(value):
		line_color = value
		update_line()
@export var counts_towards_centering = true
var id_label := Label.new()
var connect_lines := Line2D.new()
var bought := false

func _ready():
	id_label.position.y = -20
	id_label.add_theme_font_size_override("font_size", 20)
	connect_lines.z_index = -1
	for i in get_children(true):
		if i not in get_children(false):
			remove_child(i)
			i.queue_free()
	add_child(id_label, false, Node.INTERNAL_MODE_FRONT)
	add_child(connect_lines, false, Node.INTERNAL_MODE_FRONT)
	update_label()
	update_line()

func update_label():
	id_label.text = id_override if id_override != "" else "%d×%d" % [
		row, column
	]

func update_line():
	connect_lines.clear_points()
	for study in studies_required:
		connect_lines.add_point(size / 2)
		connect_lines.add_point(
			(study.position - position) + study.size / 2
		)
	connect_lines.default_color = line_color

func _process(_delta):
	if bought:
		disabled = true
		add_theme_stylebox_override("disabled", get_theme_stylebox("enabled"))
	else:
		var requirements : bool
		if needs_all_studies:
			requirements = false
			for i in studies_required:
				if not i.bought:
					requirements = true
					break
		else:
			requirements = true
			for i in studies_required:
				if not i.bought:
					requirements = false
					break
		remove_theme_stylebox_override("disabled")
		if Engine.is_editor_hint():
			disabled = not requirements
		else:
			disabled = (cost > Globals.Studies.ST.to_float()) or not requirements
