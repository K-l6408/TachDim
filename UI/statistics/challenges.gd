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
	if not Globals.Achievemer.is_unlocked(6, 3) and sum <= 30 and sum > 0:
		Globals.Achievemer.set_unlocked(6, 3)
	
	if Globals.TachTotal.log10() < Globals.ECUnlocks[0]:
		$ETable.hide()
		$Table.anchor_right = 0.5
		$Table.anchor_left  = 0.5
	else:
		$ETable.show()
		
		sum = 0
		for i in 7:
			get_node("ETable/C%d" % (i+1)).text = "EC" + Globals.int_to_string(i+1)
			get_node("ETable/T%d" % (i+1)).text = \
			Globals.format_time(Globals.ECTimes[i]) if Globals.ECTimes[i] > 0 else "N/A"
			if Globals.ECTimes.size() == i:
				Globals.ECTimes.append(-1)
			sum += Globals.ECTimes[i]
			if Globals.ECTimes[i] < 0: sum = -999
		$"ETable/T+".text = Globals.format_time(sum) if sum > 0 else "N/A"
		
		$Table.anchor_right = 0.4
		$Table.anchor_left  = 0.4
		$ETable.anchor_right = 0.6
		$ETable.anchor_left  = 0.6
