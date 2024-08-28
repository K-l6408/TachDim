extends Control

func _process(_delta):
	for i in 11:
		for j in range(1,4):
			$Eternity/Table.get_child(i*4+4+j).text = "Not done yet"
	match $Eternity/Button.status:
		0:
			$Eternity/Button.text = "Currently showing\nEternity Points"
			$Eternity/Table/E.text = "EP"
			$Eternity/Table/S.text = "EP/sec"
		1:
			$Eternity/Button.text = "Currently showing\nEternities"
			$Eternity/Table/E.text = "Eternities"
			$Eternity/Table/S.text = "Eternities/sec"
		2:
			$Eternity/Button.text = "Currently showing\nResources"
			$Eternity/Table/E.text = "EP"
			$Eternity/Table/S.text = "Eternities"
		3:
			$Eternity/Button.text = "Currently showing\nResource gain rate"
			$Eternity/Table/E.text = "EP/sec"
			$Eternity/Table/S.text = "Eternities/sec"
	
	var tt = 0
	var te = largenum.new(0)
	var ts = largenum.new(0)
	
	for i in Globals.last10etern.size():
		var e = Globals.last10etern[i]
		$Eternity/Table.get_child(i*4+7).text = Globals.float_to_string(e.time) + " " + \
		$Eternity/Table/S.text
		tt += e.time
	
	for i in Globals.last10etern.size():
		var e = Globals.last10etern[i]
		var value : largenum
		match $Eternity/Button.status:
			0, 2:
				value = e.epgain
			1:
				value = e.eternities
			3:
				value = e.epgain.divide(e.time)
		$Eternity/Table.get_child(i*4+6).text = value.to_string() + " " + \
		$Eternity/Table/E.text
		te.add2self(value)
	
	for i in Globals.last10etern.size():
		var e = Globals.last10etern[i]
		var value : largenum
		match $Eternity/Button.status:
			0:
				value = e.epgain.divide(e.time)
			1, 3:
				value = e.eternities.divide(e.time)
			2:
				value = e.eternities
		$Eternity/Table.get_child(i*4+7).text = value.to_string() + " " + \
		$Eternity/Table/S.text
		ts.add2self(value)
	
	if Globals.last10etern.size() > 0: tt /= Globals.last10etern.size()
	te.div2self(Globals.last10etern.size())
	ts.div2self(Globals.last10etern.size())
	
	$Eternity/Table/TAv.text = Globals.format_time(tt)
	$Eternity/Table/EAv.text = te.to_string() + " " + $Eternity/Table/E.text
	$Eternity/Table/SAv.text = ts.to_string() + " " + $Eternity/Table/S.text
	
	for i in Globals.last10etern.size():
		var e = Globals.last10etern[i]
		$Eternity/Table.get_child(i*4+5).text = Globals.format_time(e.time)
