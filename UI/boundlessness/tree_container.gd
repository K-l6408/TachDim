@tool
extends Container
class_name StudyTreeContainer

func _ready():
	queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN \
	or what == NOTIFICATION_CHILD_ORDER_CHANGED:
		sort()

func sort():
	var rows = []
	for i in get_children():
		if i is Study:
			while rows.size() <= i.row:
				rows.append([])
			rows[i.row].append(i)
	custom_minimum_size = Vector2(0,0)
	var row_y = 20
	for row in rows:
		var total_x = 0
		var center_x = 0
		var max_new_y = 0
		for study in row:
			study.position.y = row_y
			study.size = study.custom_minimum_size
			total_x += study.size.x + 10
			if study.counts_towards_centering:
				center_x += study.size.x + 10
			max_new_y = max(max_new_y, study.size.y + 20)
		if custom_minimum_size.x < total_x:
			custom_minimum_size.x = total_x
		var center = size.x / 2
		var pos = 0
		var numb = 0
		for study in row:
			study.position.x = \
			center - center_x / 2 + pos
			pos += study.size.x + 10
			numb += 1
			study.column = numb
		row_y += max_new_y
	custom_minimum_size.y = row_y + 60
	
	for i in get_children():
		if i is Study:
			i.update_line()
