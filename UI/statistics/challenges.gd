extends Control

func _process(_delta):
	var sum = 0
	for i in 15:
		get_node("Table/C%d" % (i+1)).text = "C" + Globals.int_to_string(i+1)
		get_node("Table/T%d" % (i+1)).text = \
		Globals.format_time(Globals.challengeTimes[i]) if Globals.challengeTimes[i] > 0 else "N/A"
		sum += Globals.challengeTimes[i]
		if Globals.challengeTimes[i] < 0: sum = -999
	$"Table/T+".text = Globals.format_time(sum) if sum > 0 else "N/A"
