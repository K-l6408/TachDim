extends RichTextLabel

var eternityColor : String :
	get: return get_theme_color("font_color", "ButtonEtern").to_html(false)

func _process(_delta):
	text = "[center][font_size=30]%s[/font_size]\n%s %s %s\n%s %s." % [
		"Stats",
		"You have produced a total of", Globals.TachTotal, "tachyons.",
		"You have played for", Globals.format_time(Globals.existence)
	]
	
	if Globals.progress >= Globals.Progression.Eternity:
		text += "\n\n[color=%s][font_size=30]%s[/font_size][/color]\n%s %s %s\n%s %s.\n%s %s %s" % [
			eternityColor,
			"Eternity",
			"You have", Globals.Eternities, "Eternities.",
			"Your fastest Eternity was", Globals.format_time(Globals.fastestEtern.time),
			"You have spent", Globals.format_time(Globals.eternTime), "in this Eternity."
		]
