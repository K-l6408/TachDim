@tool
extends Button

var score := 0.0

func _process(delta):
	if not Engine.is_editor_hint(): 
		score = sin(Time.get_ticks_msec() / 2000.0)
		$Accuracy.position.x = (
			(score * (size.x - 20)) + size.x - $Accuracy.size.x
		) / 2
		score = 1 - abs(score)
	material.set_shader_parameter("pixelsize", 1./size.x)

func _on_pressed():
	emit_signal("rewind", score)

signal rewind(score)
