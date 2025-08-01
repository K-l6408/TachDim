extends RichTextLabel

const PLANCK_LOG = 43.2683
var secondsInPlanckTime = largenum.ten_to_the(PLANCK_LOG)
var eternityColor : String :
	get: return get_theme_color("font_color", "ButtonEtern").to_html(false)
var boundlessColor : String :
	get: return get_theme_color("font_color", "ButtonBLess").to_html(false)

func _process(_delta):
	text = "[center][font_size=30]%s[/font_size]\n%s %s %s\n%s %s." % [
		"Stats",
		"You have produced a total of", Globals.TachTotal, "tachyons.",
		"You have played for", Globals.format_time(Globals.existence)
	]
	
	if Currencies.Tachyons.AMOUNT.less(secondsInPlanckTime):
		var div = secondsInPlanckTime.divide(Currencies.Tachyons.AMOUNT)
		if div.exponent > 0:
			if Currencies.Tachyons.AMOUNT.log10() < 31:
				var units := [
					"", "milli", "micro", "nano",
					"pico", "femto", "atto",
					"zepto", "yocto", "ronto", "quecto"
				]
				var log1000 = Currencies.Tachyons.AMOUNT.log10() / 3
				var mantiss = 1000.0 ** (log1000 - round(log1000))
				log1000 = round(log1000)
				
				var str1 = "%s tachyons" % Globals.float_to_string(mantiss, 1)
				var str2 = units[log1000] + "second"
				if mantiss < 1:
					str1 = "a tachyon"
					str2 = "%s %ss" % [Globals.float_to_string(1. / mantiss), str2]
				text += "\n\nIf you counted %s every %s, you'd count them all in a second." % [
					str1, str2
				]
			else:
				text += "\n\nIf you counted a tachyon each " + \
				div.to_string() + " Planck times, you'd count them all in a second."
	else:
		text += "\n\nIf you counted a tachyon each planck time, it would take "
		
		var seconds = 10 ** (Currencies.Tachyons.AMOUNT.log10() - PLANCK_LOG)
		var days = seconds / 3600 / 24
		var years = days / 365.2422
		
		if   years < 2:
			text += Globals.format_time(seconds)
		elif years < 73.17:
			text += "%s of the average human life expectancy" % \
			Globals.percent_to_string(years / 73.17)
		elif years < 25800:
			text += "%s average human lifespans" % \
			Globals.float_to_string(years / 73.17)
		elif years < 1e10:
			text += "%s precessions of the Earth's axis" %\
			Globals.float_to_string(years / 25800)
		elif years < 1e300:
			text += "%s times the current age of the Universe" %\
			Globals.float_to_string(years / 1380000000)
		
		text += " to count all your tachyons."
	
	if Globals.progress >= Globals.Progression.Permanence:
		text += "\n\n[color=%s][font_size=30]%s[/font_size][/color]\n%s %s %s%s%s.\n" % [
			eternityColor,
			"Permanence",
			"You have", Currencies.Permanences.AMOUNT.to_string().trim_suffix(".00"), "Permanence",
			"" if Currencies.Permanences.AMOUNT.to_float() == 1 else "s",
			" this Boundlessness" if Globals.Boundlessnesses.to_float() > 0 else "",
		]
		if Globals.fastestEtern.time > 0:
			text += "Your fastest Permanence %stook %s.\n" % [
				"this Boundlessness " if Globals.Boundlessnesses.to_float() > 0 else "",
				Globals.format_time(Globals.fastestEtern.time)
			]
		else:
			text += "You have no fastest Permanence%s.\n" % [
				" this Boundlessness" if Globals.Boundlessnesses.to_float() > 0 else "",
			]
		text += "You have spent %s in this Permanence." % Globals.format_time(Globals.eternTime)
	
	if Globals.progress >= Globals.Progression.Transcendence:
		text += "\n\n[color=%s][font_size=30]%s[/font_size][/color]\n%s %s %s\n%s %s.\n%s %s %s" % [
			boundlessColor,
			"Transcendence",
			"You have", Globals.Boundlessnesses.to_string().trim_suffix(".00"), "Transcendences.",
			"Your fastest Transcendence was", Globals.format_time(Globals.fastestBLess.time),
			"You have spent", Globals.format_time(Globals.boundTime), "in this Transcendence."
		]
