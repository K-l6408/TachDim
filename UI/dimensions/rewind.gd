@tool
extends Button

@export var smol := false
var n := 1
var m := 1

func _process(delta):
	if not Engine.is_editor_hint():
		if TachyonDims.rewindScore() == 1 and m == n:
			n *= -1
		else:
			m = n
		
		if smol:
			var j = TachyonDims.rewindBoost().\
			divide(TachyonDims.RewindMult)
			if j.exponent < 0 or disabled:
				text = ""
				disabled = true
			else: text = "×%s" % j.to_string()
		
		$Accuracy.position.x = (
			((1 - TachyonDims.rewindScore()) * n * (size.x - 20)) + size.x - $Accuracy.size.x
		) / 2
		if get_theme_stylebox("normal") is StyleBoxFlat:
			$Accuracy.color = get_theme_stylebox("normal").border_color
			material.set_shader_parameter("ignore", get_theme_stylebox("normal").border_color)
		else:
			$Accuracy.color = Color.WHITE
		
		material.set_shader_parameter("disabled", disabled)
		if Globals.Achievemer.is_unlocked(2, 4):
			var M = TachyonDims.RewindMult.log2()
			var B = TachyonDims.rewindBoost().log2()
			if Globals.Achievemer.is_unlocked(2, 4): B -= M
			B /= TachyonDims.rewindScore()
			if Globals.Achievemer.is_unlocked(2, 4): B += M
			material.set_shader_parameter("zoom", max(M / (B - M) + 1, 1))
		else:
			material.set_shader_parameter("zoom", 1.0)
		
	material.set_shader_parameter("pixelsize", 1./size.x)

func _on_pressed():
	TachyonDims.rewind()
