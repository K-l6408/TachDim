extends Control

func _ready():
	$"Auto/Buyers/Big Bang/Interval".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.BIG_BANG))
	$"Auto/Buyers/TGalaxy/Interval1".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.GALAXY))
	$"Auto/Buyers/Dilation/Interval1".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.DILATION))
	%"Oðers/Rewind/Interval".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.REWIND))
	%"PreInf/Timespeed/Interval".\
	connect("pressed", Autobuyers.improve_interval.bind(Autobuyers.TIMESPEED))
	for i in 8:
		%PreInf.get_node("TD%d/Interval" % (i+1)).\
		connect("pressed", Autobuyers.improve_interval.bind(i+1))
	
	%"Oðers/Rewind/Accuracy".\
	connect("pressed", Autobuyers.improve_rewd_accuracy)
	
	%"Oðers/Rewind/LineEdit".\
	connect("value_changed",
	func(val): Autobuyers.RewindObjective = val)
	
	$Auto/Buyers/Dilation/Limit.\
	connect("value_changed",
	func(val): Autobuyers.DilLimit = val)
	$Auto/Buyers/TGalaxy/Limit.\
	connect("value_changed",
	func(val): Autobuyers.GalLimit = val)
	
	$Auto/Buyers/Dilation/Interval2.\
	connect("value_changed",
	func(val): Autobuyers.DilaTimeOverride = val)
	$Auto/Buyers/TGalaxy/Interval2.\
	connect("value_changed",
	func(val): Autobuyers.GalaTimeOverride = val)
	
	$"Auto/Buyers/Big Bang/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.BIG_BANG))
	$"Auto/Buyers/TGalaxy/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.GALAXY))
	$"Auto/Buyers/Dilation/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.DILATION))
	%"Oðers/Rewind/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.REWIND))
	%"PreInf/Timespeed/Enabled".\
	connect("toggled", Autobuyers.set_enabled.bind(Autobuyers.TIMESPEED))
	
	$"Auto/Buyers/TGalaxy/Mode".\
	connect("toggled", Autobuyers.change_mode.bind(Autobuyers.GALAXY))
	$"Auto/Buyers/Dilation/Mode".\
	connect("toggled", Autobuyers.change_mode.bind(Autobuyers.DILATION))
	%"PreInf/Timespeed/Mode".\
	connect("toggled", Autobuyers.change_mode.bind(Autobuyers.TIMESPEED))
	for i in 8:
		%PreInf.get_node("TD%d/Enabled" % (i+1)).\
		connect("toggled", Autobuyers.set_enabled.bind(i+1))
		%PreInf.get_node("TD%d/Mode" % (i+1)).\
		connect("toggled", Autobuyers.change_mode.bind(i+1))
	
	$"Auto/Buyers/Big Bang/Mode".\
	connect("item_selected", Autobuyers.set_big_bang_mode)
	$"Auto/Buyers/Big Bang/Objective".\
	connect("text_submitted", Autobuyers.update_bigbang_pp)
	
	for i in 9:
		%PreInf.get_node("Locked%d" % (i+1)).\
		connect("pressed", Autobuyers.unlock_buyer.bind(i+1))

func _process(_delta):
	
	# hiding buyers locked cause of challenges
	%Oðers/Rewind          .visible = Globals.challengeCompleted(10)
	$"Auto/Buyers/Dilation".visible = Globals.challengeCompleted(11)
	$"Auto/Buyers/TGalaxy" .visible = Globals.challengeCompleted(12)
	$"Auto/Buyers/Big Bang".visible = Globals.challengeCompleted(14)
	
	# hiding dilation/galaxy buy max mode if locked
	if Permanence.overcome_upgrade_bought(2):
		$Auto/Buyers/Dilation/Limit.hide()
		$Auto/Buyers/Dilation/Mode.show()
		
		if $Auto/Buyers/Dilation/Mode.button_pressed:
			$Auto/Buyers/Dilation/Interval2.show()
			$Auto/Buyers/Dilation/Interval1.hide()
		else:
			$Auto/Buyers/Dilation/Interval1.show()
			$Auto/Buyers/Dilation/Interval2.hide()
	else:
		$Auto/Buyers/Dilation/Limit.show()
		$Auto/Buyers/Dilation/Mode.hide()
		$Auto/Buyers/Dilation/Interval1.show()
		$Auto/Buyers/Dilation/Interval2.hide()
	
	if false:
		$Auto/Buyers/TGalaxy/Limit.hide()
		$Auto/Buyers/TGalaxy/Mode.show()
		
		if $Auto/Buyers/TGalaxy/Mode.button_pressed:
			$Auto/Buyers/TGalaxy/Interval2.show()
			$Auto/Buyers/TGalaxy/Interval1.hide()
		else:
			$Auto/Buyers/TGalaxy/Interval1.show()
			$Auto/Buyers/TGalaxy/Interval2.hide()
	else:
		$Auto/Buyers/TGalaxy/Limit.show()
		$Auto/Buyers/TGalaxy/Mode.hide()
		$Auto/Buyers/TGalaxy/Interval1.show()
		$Auto/Buyers/TGalaxy/Interval2.hide()
	
	# hiding panel2 if it's empty
	var panel2 = false
	for i in %Oðers.get_children():
		if i.visible:
			panel2 = true
			break
	$Auto/Buyers/Panel2.visible = panel2
	
	# extra bang autobuyer setting
	if Globals.progressBL < GL.Progression.Overcome:
		#$"Auto/Buyers/Big Bang/Mode".hide()
		$"Auto/Buyers/Big Bang/Interval".show()
		$"Auto/Buyers/Big Bang/Objective".hide()
	else:
		#$"Auto/Buyers/Big Bang/Mode".show()
		$"Auto/Buyers/Big Bang/Interval".hide()
		$"Auto/Buyers/Big Bang/Objective".show()
		$"Auto/Buyers/Big Bang/Objective/Label".text = "(%s)" % \
		Autobuyers.BigBangObjective.to_string()
	
	# handling locked pre-inf autobuyers
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
			TachyonDims.topTachyonsInPermanence.less(largenum.ten_to_the(20 + i * 10))
			panel.hide()
	
	
	if $Auto/Buyers/Dilation/Mode.button_pressed != \
	Autobuyers.get_bit(Autobuyers.NormModes, Autobuyers.DILATION):
		$Auto/Buyers/Dilation/Mode.button_pressed = \
		Autobuyers.get_bit(Autobuyers.NormModes, Autobuyers.DILATION)
	
	if  $Auto/Buyers/Dilation/Limit.value != Autobuyers.DilLimit:
		$Auto/Buyers/Dilation/Limit.set_value_no_signal(Autobuyers.DilLimit)
	
	if  $Auto/Buyers/Dilation/Interval2.value != Autobuyers.DilaTimeOverride:
		$Auto/Buyers/Dilation/Interval2.set_value_no_signal(Autobuyers.DilaTimeOverride)
	
	if $Auto/Buyers/Dilation/Enabled.button_pressed != \
	Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.DILATION):
		$Auto/Buyers/Dilation/Enabled.button_pressed = \
		Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.DILATION)
	
	if  %Oðers/Rewind/LineEdit.value != Autobuyers.RewindObjective:
		%Oðers/Rewind/LineEdit.set_value_no_signal(Autobuyers.RewindObjective)
	
	if $Auto/Buyers/TGalaxy/Mode.button_pressed != \
	Autobuyers.get_bit(Autobuyers.NormModes, Autobuyers.GALAXY):
		$Auto/Buyers/TGalaxy/Mode.button_pressed = \
		Autobuyers.get_bit(Autobuyers.NormModes, Autobuyers.GALAXY)
	
	if  $Auto/Buyers/TGalaxy/Limit.value != Autobuyers.GalLimit:
		$Auto/Buyers/TGalaxy/Limit.set_value_no_signal(Autobuyers.GalLimit)
	
	if  $Auto/Buyers/TGalaxy/Interval2.value != Autobuyers.GalaTimeOverride:
		$Auto/Buyers/TGalaxy/Interval2.set_value_no_signal(Autobuyers.GalaTimeOverride)
	
	if $Auto/Buyers/TGalaxy/Enabled.button_pressed != \
	Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.GALAXY):
		$Auto/Buyers/TGalaxy/Enabled.button_pressed = \
		Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.GALAXY)
	
	if $"Auto/Buyers/Big Bang/Enabled".button_pressed != \
	Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.BIG_BANG):
		$"Auto/Buyers/Big Bang/Enabled".button_pressed = \
		Autobuyers.get_bit(Autobuyers.NormEnabled, Autobuyers.BIG_BANG)
	
	if $"Auto/Buyers/Big Bang/Objective".text != \
	Autobuyers.BigBangObjectStr and not \
	$"Auto/Buyers/Big Bang/Objective".has_focus():
		$"Auto/Buyers/Big Bang/Objective".text = Autobuyers.BigBangObjectStr
	
	for panel in $Auto/Buyers.get_children():
		if panel.has_node("Mode"):
			if panel.get_node("Mode").button_pressed:
				panel.get_node("Mode").text = " Buys max "
			else:
				panel.get_node("Mode").text = "Buys singles"
		if panel.has_node("Enabled"):
			if panel.get_node("Enabled").button_pressed:
				panel.get_node("Enabled").text = "Enabled"
			else:
				panel.get_node("Enabled").text = "Disabled"
	for panel in %Oðers.get_children():
		if panel.has_node("Enabled"):
			if panel.get_node("Enabled").button_pressed:
				panel.get_node("Enabled").text = "Enabled"
			else:
				panel.get_node("Enabled").text = "Disabled"
	
	if Autobuyers.DilInterval() <= 0.1:
		$Auto/Buyers/Dilation/Interval1.disabled = true
		$Auto/Buyers/Dilation/Interval1.text = "%s: %s" % [
			"Interval",
			Globals.format_time(Autobuyers.DilInterval())
		]
	else:
		$Auto/Buyers/Dilation/Interval1.disabled = \
		Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.DilUpgrades - 0.001)
		$Auto/Buyers/Dilation/Interval1.text = "%s: %s → %s\n%s: %s PP" % [
			"Interval",
			Globals.format_time(Autobuyers.DilInterval()),
			Globals.format_time(max(Autobuyers.DilInterval() * 0.6, 0.1)),
			"Cost",
			Globals.float_to_string(2 ** Autobuyers.DilUpgrades, 1),
		]
	
	if Autobuyers.RewdInterval() <= 0.1:
		%Oðers/Rewind/Interval.disabled = true
		%Oðers/Rewind/Interval.text = "%s: %s" % [
			"Interval",
			Globals.format_time(Autobuyers.RewdInterval()),
		]
	else:
		%Oðers/Rewind/Interval.disabled = \
		Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.RewdUpgrades - 0.001)
		%Oðers/Rewind/Interval.text = "%s: %s → %s\n%s: %s PP" % [
			"Interval",
			Globals.format_time(Autobuyers.RewdInterval()),
			Globals.format_time(max(Autobuyers.RewdInterval() * 0.6, 0.1)),
			"Cost",
			Globals.float_to_string(2 ** Autobuyers.RewdUpgrades, 1),
		]
	
	if Autobuyers.GalInterval() <= 0.1:
		$Auto/Buyers/TGalaxy/Interval1.disabled = true
		$Auto/Buyers/TGalaxy/Interval1.text = "%s: %s" % [
			"Interval",
			Globals.format_time(Autobuyers.GalInterval())
		]
	else:
		$Auto/Buyers/TGalaxy/Interval1.disabled = \
		Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.GalUpgrades - 0.001)
		$Auto/Buyers/TGalaxy/Interval1.text = "%s: %s → %s\n%s: %s PP" % [
			"Interval",
			Globals.format_time(Autobuyers.GalInterval()),
			Globals.format_time(max(Autobuyers.GalInterval() * 0.6, 0.1)),
			"Cost",
			Globals.float_to_string(2 ** Autobuyers.GalUpgrades, 1),
		]
	
	if Autobuyers.GalInterval() <= 0.1:
		$"Auto/Buyers/Big Bang/Interval".disabled = true
		$"Auto/Buyers/Big Bang/Interval".text = "%s: %s" % [
			"Interval",
			Globals.format_time(Autobuyers.BangInterval())
		]
	else:
		$"Auto/Buyers/Big Bang/Interval".disabled = \
		Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.BangUpgrades - 0.001)
		$"Auto/Buyers/Big Bang/Interval".text = "%s: %s → %s\n%s: %s PP" % [
			"Interval",
			Globals.format_time(Autobuyers.BangInterval()),
			Globals.format_time(max(Autobuyers.BangInterval() * 0.6, 0.1)),
			"Cost",
			Globals.float_to_string(2 ** Autobuyers.BangUpgrades, 1),
		]
	
	if Autobuyers.RewdAccuracy() >= 1:
		%Oðers/Rewind/Accuracy.disabled = true
		%Oðers/Rewind/Accuracy.text = "%s: %s" % [
			"Accuracy",
			Globals.percent_to_string(Autobuyers.RewdAccuracy(), 1)
		]
	else:
		%Oðers/Rewind/Accuracy.disabled = \
		Currencies.PermanencePts.AMOUNT.less(3 ** Autobuyers.RewdAQups - 0.001)
		%Oðers/Rewind/Accuracy.text = "%s: %s → %s\n%s: %s PP" % [
			"Accuracy",
			Globals.percent_to_string(Autobuyers.RewdAccuracy(), 1),
			Globals.percent_to_string(min(Autobuyers.RewdAccuracy() * 1.095, 1), 1),
			"Cost",
			Globals.float_to_string(3 ** Autobuyers.RewdAQups, 1),
		]
	
	for i in 9:
		if i == 0: # timespeed
			var panel = %PreInf/Timespeed
			if not Globals.challengeCompleted(9):
				panel.get_node("Mode").disabled = true
				panel.get_node("Interval").disabled = true
				panel.get_node("Mode").text = "Complete the challenge\nto change the mode"
				panel.get_node("Interval").text = "Interval: %s\n(Complete the challenge to upgrade)" % \
				Globals.format_time(Autobuyers.TSpeedInterval())
			else:
				panel.get_node("Mode").disabled = false
				if panel.get_node("Mode").button_pressed:
					panel.get_node("Mode").text = " Buys max "
				else:
					panel.get_node("Mode").text = "Buys singles"
				
				if Autobuyers.TSpeedInterval() <= 0.1:
					panel.get_node("Interval").disabled = true
					panel.get_node("Interval").text = "%s: %s" % [
						"Interval",
						Globals.format_time(Autobuyers.TSpeedInterval())
					]
				else:
					panel.get_node("Interval").disabled = \
					Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.NormUpgrades[8] - 0.001)
					panel.get_node("Interval").text = "%s: %s → %s\n%s: %s PP" % [
						"Interval",
						Globals.format_time(Autobuyers.TSpeedInterval()),
						Globals.format_time(max(Autobuyers.TSpeedInterval() * 0.6, 0.1)),
						"Cost",
						Globals.float_to_string(2 ** Autobuyers.NormUpgrades[8], 1),
					]
			
			if panel.get_node("Enabled").button_pressed:
				panel.get_node("Enabled").text = "Enabled"
			else:
				panel.get_node("Enabled").text = "Disabled"
			
			if Globals.Achievemer.is_unlocked(5, 3):
				panel.custom_minimum_size.x = 300
				panel.get_node("Label").anchor_right = 0.3
				panel.get_node("Mode") .anchor_left  = 0.3
				panel.get_node("Mode") .anchor_right = 0.7
				panel.get_node("Interval").hide()
			else:
				panel.custom_minimum_size.x = 620
				panel.get_node("Label").anchor_right = 0.2
				panel.get_node("Mode") .anchor_right = 0.8
				panel.get_node("Mode") .anchor_left  = 0.5
				panel.get_node("Interval").show()
			
			if panel.get_node("Mode").button_pressed != \
			Autobuyers.get_bit(
				Autobuyers.NormModes, Autobuyers.TIMESPEED
			):
				panel.get_node("Mode").button_pressed = \
				Autobuyers.get_bit(
					Autobuyers.NormModes, Autobuyers.TIMESPEED
				)
			
			if panel.get_node("Enabled").button_pressed != \
			Autobuyers.get_bit(
				Autobuyers.NormEnabled, Autobuyers.TIMESPEED
			):
				panel.get_node("Enabled").button_pressed = \
				Autobuyers.get_bit(
					Autobuyers.NormEnabled, Autobuyers.TIMESPEED
				)
		else:
			var panel = %PreInf.get_node("TD%d" % i)
			if not Globals.challengeCompleted(i):
				panel.get_node("Interval").disabled = true
				panel.get_node("Interval").text = "Interval: %s\n(Complete the challenge to upgrade)" % \
				Globals.format_time(Autobuyers.TDInterval(i))
			else:
				if Autobuyers.TDBulk(i) >= 512:
					panel.get_node("Interval").text = "%s: %s\n%s: ×%s" % [
							"Interval",
							Globals.format_time(Autobuyers.TDInterval(i)),
							"Bulk",
							Globals.int_to_string(Autobuyers.TDBulk(i)),
						]
				else:
					panel.get_node("Interval").disabled = \
					Currencies.PermanencePts.AMOUNT.less(2 ** Autobuyers.NormUpgrades[i-1] - 0.001)
					if Autobuyers.NormUpgrades[i-1] < Autobuyers.IntervalCap[i-1]:
						panel.get_node("Interval").text = "%s: %s → %s\n%s: %s PP" % [
							"Interval",
							Globals.format_time(Autobuyers.TDInterval(i)),
							Globals.format_time(max(Autobuyers.TDInterval(i) * 0.6, 0.1)),
							"Cost",
							Globals.float_to_string(2 ** Autobuyers.NormUpgrades[i-1], 1),
						]
					else:
						panel.get_node("Interval").text = "%s: ×%s → ×%s\n%s: %s PP" % [
							"Bulk",
							Globals.int_to_string(Autobuyers.TDBulk(i)),
							Globals.int_to_string(Autobuyers.TDBulk(i) * 2),
							"Cost",
							Globals.float_to_string(2 ** Autobuyers.NormUpgrades[i-1], 1),
						]
			
			if panel.get_node("Mode").button_pressed:
				if Autobuyers.TDBulk(i) == INF:
					panel.get_node("Mode").text = " Buys max "
				else:
					panel.get_node("Mode").text = "Buys %ss" % \
					Globals.int_to_string(TachyonDims.buylim * Autobuyers.TDBulk(i))
			else:
				panel.get_node("Mode").text = "Buys singles"
			
			if panel.get_node("Enabled").button_pressed:
				panel.get_node("Enabled").text = "Enabled"
			else:
				panel.get_node("Enabled").text = "Disabled"
			
			if panel.get_node("Mode").button_pressed != \
			Autobuyers.get_bit(Autobuyers.NormModes, i):
				panel.get_node("Mode").button_pressed = \
				Autobuyers.get_bit(Autobuyers.NormModes, i)
			
			if panel.get_node("Enabled").button_pressed != \
			Autobuyers.get_bit(Autobuyers.NormEnabled, i):
				panel.get_node("Enabled").button_pressed = \
				Autobuyers.get_bit(Autobuyers.NormEnabled, i)
			
			if Autobuyers.TDBulk(i) == INF:
				panel.custom_minimum_size.x = 250
				panel.get_node("Label").text = Globals.ordinal(i) + " TD"
				panel.get_node("Label").anchor_right = 0.3
				panel.get_node("Mode") .anchor_left  = 0.3
				panel.get_node("Mode") .anchor_right = 0.7
				panel.get_node("Interval").hide()
			else:
				panel.custom_minimum_size.x = 620
				panel.get_node("Label").text = Globals.ordinal(i) + " Tachyon Dimension Autobuyer"
				panel.get_node("Label").anchor_right = 0.2
				panel.get_node("Mode") .anchor_right = 0.8
				panel.get_node("Mode") .anchor_left  = 0.5
				panel.get_node("Interval").show()
