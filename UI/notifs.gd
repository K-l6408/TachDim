extends Control

var last_y = 2

func _process(delta):
	for i in get_children():
		i.position.x -= delta * 100
		if  i.position.x < -i.size.x - 10:
			i.position.x = -i.size.x - 10
	if get_child_count() > 0:
		if get_child(0).position.x <= -get_child(0).size.x:
			position.y -= delta * 40
	if position.y <= -30:
		for i in get_children():
			i.position.y -= $"../NotifDeft/Panel".size.y
		last_y -= $"../NotifDeft/Panel".size.y
		get_child(0).queue_free()
		position.y = 0

func notif(type:String, text:String):
	var lab = $"../NotifDeft".duplicate()
	lab.position = Vector2(7, last_y)
	lab.visible  = true
	lab.text     = text
	last_y += $"../NotifDeft/Panel".size.y
	add_child(lab)
	lab.get_node("Panel").modulate = \
	load(ProjectSettings.get("gui/theme/custom")).get_color(type, "NotificationPanel")
