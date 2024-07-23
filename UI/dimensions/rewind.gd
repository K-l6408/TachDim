@tool
extends Button

var score := 0.0

func _process(_delta):
	if not Engine.is_editor_hint(): 
		score = sin(Time.get_ticks_msec() / 2000.0)
		$Accuracy.position.x = (
			(score * (size.x - 20)) + size.x - $Accuracy.size.x
		) / 2
		if Globals.Achievemer.is_unlocked(2, 4):
			score *= .75
			material.set_shader_parameter("zoom", 4./3.)
		else:
			material.set_shader_parameter("zoom", 1.0)
		score = 1 - abs(score)
	material.set_shader_parameter("pixelsize", 1./size.x)

func _on_pressed():
	emit_signal("rewind", score)
	if score >= 0.9:
		if not Globals.Achievemer.is_unlocked(2, 4):
			Globals.Achievemer.set_unlocked(2, 4)

signal rewind(score)
