extends Control

func _process(_delta):
	if Globals.last10etern.is_empty():
		$Eternity.hide()
	else:
		$Eternity.show()
		setup_table($Eternity, Globals.last10etern, ["EP", "Eternities"])
	
	if Globals.last10bless.is_empty():
		$Eternity.anchor_left  = 0.5
		$Eternity.anchor_right = 0.5
		$Boundlessness.hide()
	else:
		$Eternity.anchor_left  = 0.3
		$Eternity.anchor_right = 0.3
		$Boundlessness.anchor_left  = 0.7
		$Boundlessness.anchor_right = 0.7
		$Boundlessness.show()
		setup_table($Boundlessness, Globals.last10bless, ["BP", "Boundlessnesses"])

func setup_table(node, data, currencies):
	var table  = node.get_node("Table")
	var button = node.get_node("Button")
	var row1e  = node.get_node("Table/E")
	var row1s  = node.get_node("Table/S")
	
	for i in 11:
		for j in range(1,4):
			table.get_child(i*4+4+j).text = "Not done yet"
	match button.status:
		0:
			button.text = "Currently showing\nPrestige currency"
			row1e.text = currencies[0]
			row1s.text = currencies[0] + "/sec"
		1:
			button.text = "Currently showing\nPrestige amount"
			row1e.text = currencies[1]
			row1s.text = currencies[1] + "/sec"
		2:
			button.text = "Currently showing\nResources"
			row1e.text = currencies[0]
			row1s.text = currencies[1]
		3:
			button.text = "Currently showing\nResource gain rate"
			row1e.text = currencies[0] + "/sec"
			row1s.text = currencies[1] + "/sec"
	
	var tt = 0
	var te = largenum.new(0)
	var ts = largenum.new(0)
	
	for i in data.size():
		var e = data[i]
		table.get_child(i*4+7).text = Globals.float_to_string(e.time) + " " + \
		row1s.text
		tt += e.time
	
	for i in data.size():
		var e = data[i]
		var value : largenum
		match button.status:
			0, 2:
				value = e.currency
			1:
				value = e.amount
			3:
				value = e.currency.divide(e.time)
		table.get_child(i*4+6).text = value.to_string() + " " + \
		row1e.text
		te.add2self(value)
	
	for i in data.size():
		var e = data[i]
		var value : largenum
		match button.status:
			0:
				value = e.currency.divide(e.time)
			1, 3:
				value = e.amount.divide(e.time)
			2:
				value = e.amount
		table.get_child(i*4+7).text = value.to_string() + " " + \
		row1s.text
		ts.add2self(value)
	
	if data.size() > 0: tt /= data.size()
	te.div2self(data.size())
	ts.div2self(data.size())
	
	table.get_node("TAv").text = Globals.format_time(tt)
	table.get_node("EAv").text = te.to_string() + " " + row1e.text
	table.get_node("SAv").text = ts.to_string() + " " + row1s.text
	
	for i in data.size():
		var e = data[i]
		table.get_child(i*4+5).text = Globals.format_time(e.time)
