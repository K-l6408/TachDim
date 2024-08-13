extends RichTextLabel

const PLANCK_LOG = 43.2683
var secondsInPlanckTime = largenum.ten_to_the(PLANCK_LOG)
var eternityColor : String :
	get: return get_theme_color("font_color", "ButtonEtern").to_html(false)

func _process(_delta):
	text = "[center][font_size=30]%s[/font_size]\n%s %s %s\n%s %s." % [
		"Stats",
		"You have produced a total of", Globals.TachTotal, "tachyons.",
		"You have played for", Globals.format_time(Globals.existence)
	]
	
	if Globals.Tachyons.less(secondsInPlanckTime):
		var div = secondsInPlanckTime.divide(Globals.Tachyons)
		if div.exponent > 0:
			if Globals.Tachyons.log10() < 31:
				var units := [
					"", "milli", "micro", "nano",
					"pico", "femto", "atto",
					"zepto", "yocto", "ronto", "quecto"
				]
				var log1000 = Globals.Tachyons.log10() / 3
				var mantiss = 1000.0 ** (log1000 - round(log1000))
				log1000 = round(log1000)
				
				var str1 = "%s tachyons" % Globals.float_to_string(mantiss, 1)
				var str2 = units[log1000] + "second"
				if mantiss < 1:
					str1 = "a tachyon"
					str2 = "%s %ss" % [Globals.float_to_string(1. / mantiss), str2]
				text += "\n\nIf you counted %s each %s, you'd count them all in a second." % [
					str1, str2
				]
			else:
				text += "\n\nIf you counted a tachyon each " + \
				div.to_string() + " Planck times, you'd count them all in a second."
	else:
		text += "\n\nIf you counted a tachyon each planck time, it would take "
		
		var seconds = 10 ** (Globals.Tachyons.log10() - PLANCK_LOG)
		var days = seconds / 3600 / 24
		var years = days / 365.2422
		
		if   years < 2:
			text += Globals.format_time(seconds)
		elif years < 73.17:
			text += "%s of the average human life expectancy" % \
			Globals.percent_to_string(years / 73.17)
		elif years < 25800:
			text += "%s average human life expectancies" % \
			Globals.float_to_string(years / 73.17)
		elif years < 1e90:
			text += "%s precessions of the Earth's axis" %\
			Globals.float_to_string(years / 25800)
		
		text += " to count all your tachyons."
	
	if Globals.progress >= Globals.Progression.Eternity:
		text += "\n\n[color=%s][font_size=30]%s[/font_size][/color]\n%s %s %s\n%s %s.\n%s %s %s" % [
			eternityColor,
			"Eternity",
			"You have", Globals.Eternities, "Eternities.",
			"Your fastest Eternity was", Globals.format_time(Globals.fastestEtern.time),
			"You have spent", Globals.format_time(Globals.eternTime), "in this Eternity."
		]
