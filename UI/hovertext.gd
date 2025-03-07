@tool
extends PanelContainer
class_name TooltipPanel

const Horizontal = [SIDE_LEFT, SIDE_RIGHT ]
const Vertical   = [SIDE_TOP , SIDE_BOTTOM]

var label := Label.new()
@export var direction : Side = SIDE_LEFT
@export var offset := 5

func _ready() -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	mouse_filter = MOUSE_FILTER_IGNORE
	add_child(label)
	z_index = 400
	theme_type_variation = "TooltipPanel"

func _process(delta: float) -> void:
	if get_parent() is Control:
		var parent = get_parent()
		label.text = parent.get_tooltip()
		
		if direction in Horizontal:
			label.set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
			size.x = label.size.x + 5
			size.y = parent.size.y
		if direction in Vertical:
			label.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
			size.x = parent.size.x
			size.y = label.size.y + 5
		
		match direction:
			SIDE_TOP:
				position = Vector2(
					(parent.size.x - size.x) / 2,
					-(size.y + offset)
				)
			SIDE_BOTTOM:
				position = Vector2(
					(parent.size.x - size.x) / 2,
					(parent.size.y + offset)
				)
			SIDE_LEFT:
				position = Vector2(
					-(size.x + offset),
					(parent.size.y - size.y) / 2
				)
			SIDE_RIGHT:
				position = Vector2(
					parent.size.x + offset,
					(parent.size.y - size.y) / 2
				)
		
		if Rect2(Vector2(0,0), parent.size).has_point(parent.get_local_mouse_position()) and \
		parent.get_tooltip() != "":
			# mouse INSIDE parent control
			modulate.a += delta * 5
			if modulate.a >= 1:
				modulate.a = 1
			show()
		else:
			# mouse OUTSIDE parent control
			modulate.a -= delta * 5
			if modulate.a <= 0:
				modulate.a = 0
	else: queue_free()
