extends Button

func boundlessness():
	Globals.BoundlessPts.add2self(Formulas.bpgained())
	Globals.Boundlessnesses.add2self(1)
	Globals.boundlessnessreset()
	if  Globals.progress < GL.Progression.Boundlessness:
		Globals.progress = GL.Progression.Boundlessness
