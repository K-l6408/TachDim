extends Button

func boundlessness():
	var bpgained = Formulas.bpgained()
	var time = Globals.boundTime
	Globals.BoundlessPts.add2self(bpgained)
	Globals.Boundlessnesses.add2self(1)
	Globals.boundlessnessreset()
	if  Globals.progress < GL.Progression.Boundlessness:
		Globals.progress = GL.Progression.Boundlessness
	if Globals.fastestBLess.time < 0 \
	or Globals.fastestBLess.time > time:
		Globals.fastestBLess = Globals.PrestigeData.new(time, bpgained, 1)
	Globals.last10bless.append(Globals.PrestigeData.new(time, bpgained, 1))
