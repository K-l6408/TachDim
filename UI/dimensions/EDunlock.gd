extends Button

func _process(_delta):
	if Globals.EDHandler.DimsUnlocked == 8: return
	text = "Reach %s TC\nto unlock a new\n" % \
	largenum.ten_to_the(Globals.EDHandler.TachLogReq[Globals.EDHandler.DimsUnlocked]).to_string()
	if Globals.EDHandler.DimsUnlocked == 0:
		text += "type of Dimension."
	else:
		text += "Eternity Dimension."
	disabled = (Currencies.Tachyons.AMOUNT.log10() < \
	Globals.EDHandler.TachLogReq[Globals.EDHandler.DimsUnlocked])
	if Globals.Boundlessnesses.to_float() >= 25 and not disabled:
		Globals.EDHandler.DimsUnlocked += 1
