extends Button

func boundlessness():
	Globals.BoundlessPts.add2self(Formulas.epgained())
	Globals.Boundlessnesses.add2self(1)
	Globals.boundlessnessreset()
