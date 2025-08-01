extends Button

func boundlessness():
	var tpgained = Formulas.tpgained()
	var time = Globals.boundTime
	Globals.BoundlessPts.add2self(tpgained)
	Globals.Boundlessnesses.add2self(1)
	Globals.boundlessnessreset()
	if  Globals.progress < GL.Progression.Transcendence:
		Globals.progress = GL.Progression.Transcendence
	if Globals.fastestBLess.time < 0 \
	or Globals.fastestBLess.time > time:
		Globals.fastestBLess = Globals.PrestigeData.new(time, tpgained, 1)
	Globals.last10bless.insert(0, Globals.PrestigeData.new(time, tpgained, 1))
	if  Globals.last10bless.size() > 10:
		Globals.last10bless.resize(10)
	Globals.animation(GL.Animations.Transcend)
