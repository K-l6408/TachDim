@tool
extends Button

@export var smol := false

var score := 0.0

func _process(delta):
	if not Engine.is_editor_hint(): 
		score = sin(Globals.existence / 2.0)
		
		# sine changed sign (score reached maximum)
		if sin(Globals.existence / 2.0) * \
		sin((Globals.existence - delta) / 2.0) < 0:
			score = 0
		
		$Accuracy.position.x = (
			(score * (size.x - 20)) + size.x - $Accuracy.size.x
		) / 2
		if Globals.Achievemer.is_unlocked(2, 4):
			var B = Globals.TDHandler.rewindBoost().log2()
			var M = Globals.TDHandler.RewindMult.log2()
			material.set_shader_parameter("zoom", max(M / (B - M), 1))
		else:
			material.set_shader_parameter("zoom", 1.0)
		score = 1 - abs(score)
		if smol:
			if disabled: text = ""
			else: text = "×%s" % \
				Globals.TDHandler.rewindBoost(score).divide(Globals.TDHandler.RewindMult).to_string()
	material.set_shader_parameter("pixelsize", 1./size.x)

func _on_pressed():
	emit_signal("rewind", score)
	if score >= 0.9:
		if not Globals.Achievemer.is_unlocked(2, 4):
			Globals.Achievemer.set_unlocked(2, 4)

signal rewind(score)
