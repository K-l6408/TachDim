extends Control

func _ready():
	$"Auto/Buyers/Big Bang/Interval".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.BIG_BANG))
	$"Auto/Buyers/TGalaxy/Interval".\
	connect("toggled", Autobuyers.improve_interval.bind(Autobuyers.GALAXY))
	$"Auto/Buyers/Dilation/Interval".\
	connect("toggled", Autobuyers.improve_interval.bind(Autobuyers.DILATION))
	%"PreInf/Timespeed/Interval".\
	connect("toggled", Autobuyers.improve_interval.bind(Autobuyers.TIMESPEED))
	for i in 8:
		%PreInf.get_node("TD%d/Interval" % (i+1)).\
		connect("pressed", Autobuyers.improve_interval.bind(i+1))
	
	$"Auto/Buyers/Big Bang/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.BIG_BANG))
	$"Auto/Buyers/TGalaxy/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.GALAXY))
	$"Auto/Buyers/Dilation/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.DILATION))
	%"PreInf/Timespeed/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.TIMESPEED))
	
	for i in 8:
		%PreInf.get_node("TD%d/Enabled" % (i+1)).\
		connect("toggled", Autobuyers.set_enabled.bind(i+1))
		%PreInf.get_node("TD%d/Mode" % (i+1)).\
		connect("toggled", Autobuyers.change_mode.bind(i+1))
	
	$"Auto/Buyers/Big Bang/Mode".\
	connect("item_selected", Autobuyers.set_big_bang_mode)
	$"Auto/Buyers/Big Bang/Objective".\
	connect("text_submitted", Autobuyers.update_bigbang_ep)
	
	for i in 9:
		%PreInf.get_node("Locked%d" % (i+1)).\
		connect("pressed", Autobuyers.unlock_buyer.bind(i+1))

func _process(_delta):
	$"Auto/Buyers/Dilation".visible = Globals.challengeCompleted(11)
	$"Auto/Buyers/TGalaxy" .visible = Globals.challengeCompleted(12)
	$"Auto/Buyers/Big Bang".visible = Globals.challengeCompleted(14)
	
	for i in 9:
		var panel = %PreInf/Timespeed
		if i != 8:
			panel = %PreInf.get_node("TD%d" % (i+1))
		if Autobuyers.get_bit(Autobuyers.NormUnlocked, i+1):
			%PreInf.get_node("Locked%d" % (i+1)).hide()
			panel.show()
		else:
			%PreInf.get_node("Locked%d" % (i+1)).show()
			%PreInf.get_node("Locked%d" % (i+1)).disabled = \
			TachyonDims.topTachyonsInEternity.less(largenum.ten_to_the(20 + i * 10))
			panel.hide()
	
	for i in 9:
		if i == 0: # timespeed
			var panel = %PreInf/Timespeed
			if not Globals.challengeCompleted(9):
				panel.get_node("Mode").disabled = true
				panel.get_node("Interval").disabled = true
				panel.get_node("Mode").text = "Complete the challenge\nto change the mode"
				panel.get_node("Interval").text = "Complete the challenge\nto upgrade the interval"
			else:
				panel.get_node("Mode").disabled = false
				if panel.get_node("Mode").button_pressed:
					panel.get_node("Mode").text = "Buys max"
				else:
					panel.get_node("Mode").text = "Buys singles"
				panel.get_node("Interval").disabled = \
				not Currencies.EternityPts.less(2 ** Autobuyers.NormUpgrades[8])
				panel.get_node("Interval").text = "%s: %s → %s\n%s: %s EP" % [
					"Interval",
					Globals.format_time(Autobuyers.TSpeedInterval()),
					Globals.format_time(Autobuyers.TSpeedInterval() * 0.6),
					"Cost",
					Globals.float_to_string(2 ** Autobuyers.NormUpgrades[8], 1),
				]
			
			if Autobuyers.TSpeedInterval() == 0.1:
				panel.custom_minimum_size.x = 300
				panel.get_node("Mode").anchor_left  = 0.3
				panel.get_node("Mode").anchor_right = 0.7
				panel.get_node("Interval").hide()
			else:
				panel.custom_minimum_size.x = 620
				panel.get_node("Mode").anchor_right = 0.8
				panel.get_node("Mode").anchor_left  = 0.5
				panel.get_node("Interval").show()
		else:
			var panel = %PreInf.get_node("TD%d" % i)
			if not Globals.challengeCompleted(i):
				panel.get_node("Interval").disabled = true
				panel.get_node("Interval").text = "Complete the challenge\nto upgrade the interval"
			else:
				panel.get_node("Interval").disabled = \
				not Currencies.EternityPts.less(2 ** Autobuyers.NormUpgrades[8])
				panel.get_node("Interval").text = "%s: %s → %s\n%s: %s EP" % [
					"Interval",
					Globals.format_time(Autobuyers.TDInterval(i)),
					Globals.format_time(Autobuyers.TDInterval(i) * 0.6),
					"Cost",
					Globals.float_to_string(2 ** Autobuyers.NormUpgrades[i-1], 1),
				]
			
			if panel.get_node("Mode").button_pressed:
				if Autobuyers.TDBulk(i) == INF:
					panel.get_node("Mode").text = "Buys max"
				else:
					panel.get_node("Mode").text = "Buys %ss" % \
					Globals.int_to_string(TachyonDims.buylim * Autobuyers.TDBulk(i))
			else:
				panel.get_node("Mode").text = "Buys singles"
			
			if panel.get_node("Mode").button_pressed != \
			Autobuyers.get_bit(Autobuyers.NormModes, i):
				panel.get_node("Mode").button_pressed = \
				Autobuyers.get_bit(Autobuyers.NormModes, i)
			
			if Autobuyers.TDBulk(i) == INF:
				panel.custom_minimum_size.x = 250
				panel.get_node("Label").text = Globals.ordinal(i) + " TD"
				panel.get_node("Mode").anchor_left  = 0.3
				panel.get_node("Mode").anchor_right = 0.7
				panel.get_node("Interval").hide()
			else:
				panel.custom_minimum_size.x = 620
				panel.get_node("Label").text = Globals.ordinal(i) + " Tachyon Dimension Autobuyer"
				panel.get_node("Mode").anchor_right = 0.8
				panel.get_node("Mode").anchor_left  = 0.5
				panel.get_node("Interval").show()
