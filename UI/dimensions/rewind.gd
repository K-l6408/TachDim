@tool
extends Button

@export var smol := false

var score := 0.0

func _process(delta):
	if not Engine.is_editor_hint():
		var rewspd = 0.5
		if Globals.Achievemer.is_unlocked(5, 2):
			rewspd *= 7
		
		if smol:
			var j = Globals.TDHandler.rewindBoost(score).\
			divide(Globals.TDHandler.RewindMult)
			if j.exponent < 0 or disabled:
				text = ""
				disabled = true
			else: text = "×%s" % j.to_string()
		
		score = sin(Globals.existence * rewspd)
		# sine changed sign (score reached maximum)
		if sin(Globals.existence * rewspd) * \
		sin((Globals.existence - delta) * rewspd) < 0 or \
		(Globals.existence * rewspd) - \
		((Globals.existence - delta) * rewspd) >= PI:
			score = 0
		
		$Accuracy.position.x = (
			(score * (size.x - 20)) + size.x - $Accuracy.size.x
		) / 2
		if get_theme_stylebox("normal") is StyleBoxFlat:
			$Accuracy.color = get_theme_stylebox("normal").border_color
			material.set_shader_parameter("ignore", get_theme_stylebox("normal").border_color)
		else:
			$Accuracy.color = Color.WHITE
		
		score = 1 - abs(score)
		
		material.set_shader_parameter("disabled", disabled)
		if Globals.Achievemer.is_unlocked(2, 4):
			var B = Globals.TDHandler.rewindBoost().log2()
			var M = Globals.TDHandler.RewindMult.log2()
			material.set_shader_parameter("zoom", max(M / (B - M) + 1, 1))
		else:
			material.set_shader_parameter("zoom", 1.0)
		
	material.set_shader_parameter("pixelsize", 1./size.x)

func _on_pressed():
	emit_signal("rewind", score)
	if score >= 0.9:
		if not Globals.Achievemer.is_unlocked(2, 4):
			Globals.Achievemer.set_unlocked(2, 4)

signal rewind(score)
