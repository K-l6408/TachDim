@tool
extends PanelContainer
class_name TooltipPanel

enum Direction {
	UP, DOWN, LEFT, RIGHT
}
const Horizontal = [Direction.LEFT, Direction.RIGHT]
const Vertical   = [Direction.UP  , Direction.DOWN ]

var label := Label.new()
@export var direction : Direction

func _ready() -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = MOUSE_FILTER_IGNORE
	mouse_filter = MOUSE_FILTER_IGNORE
	add_child(label)
	z_index = 400

func _process(delta: float) -> void:
	if get_parent() is Control:
		var parent = get_parent()
		label.text = parent.get_tooltip()
		
		if direction in Horizontal:
			label.set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
			if visible:
				size.x = label.size.x + 5
				size.y = parent.size.y
		if direction in Vertical:
			label.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
			if visible:
				size.x = parent.size.x
				size.y = label.size.y + 5
		
		match direction:
			Direction.UP:
				position = Vector2(0,-(size.y + 5))
			Direction.DOWN:
				position = Vector2(0, parent.size.y + 5)
			Direction.LEFT:
				position = Vector2(-(size.x + 5), 0)
			Direction.RIGHT:
				position = Vector2(parent.size.x + 5, 0)
		
		if Rect2(Vector2(0,0), parent.size).has_point(parent.get_local_mouse_position()) and \
		parent.get_tooltip() != "":
			# mouse INSIDE parent control
			modulate.a += delta * 5
			if modulate.a >= 1: modulate.a = 1
			show()
		else:
			# mouse OUTSIDE parent control
			modulate.a -= delta * 5
			if modulate.a <= 0:
				modulate.a = 0
				hide()
	else: queue_free()
