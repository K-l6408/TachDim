@tool
extends GridContainer

@export var color := Color(1,1,1)
@export var last  := true

func _draw():
	var hs = get_theme_constant("h_separation")
	var vs = get_theme_constant("v_separation")
	var j = hs / 2
	for i in columns-1:
		draw_line(
			Vector2(get_child(i).size.x + j, 0),
			Vector2(get_child(i).size.x + j, size.y),
			color, 2)
		j += get_child(i).size.x + hs
	draw_line(
		Vector2(0,      get_child(0).size.y + vs/2 - 1),
		Vector2(size.x, get_child(0).size.y + vs/2 - 1),
		color, 2)
	if last:
		draw_line(
			Vector2(0,      size.y - get_child(get_child_count() - 1).size.y - vs/2),
			Vector2(size.x, size.y - get_child(get_child_count() - 1).size.y - vs/2),
			color, 2)

func _process(delta):
	queue_redraw()
