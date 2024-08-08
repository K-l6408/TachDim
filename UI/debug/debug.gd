extends Control

func evil():
	var oper = ""
	match $Operation.selected:
		0:
			oper = "_init"
		1:
			oper = "add2self"
		2:
			oper = "mult2self"
		3:
			oper = "pow2self"
	match $Resource.selected:
		0:
			Globals.Tachyons.call(oper, $LineEdit.text.to_float())
		1:
			Globals.TachTotal.call(oper, $LineEdit.text.to_float())
		2:
			match $Operation.selected:
				0: Globals.existence   = $LineEdit.text.to_float()
				1: Globals.existence  += $LineEdit.text.to_float()
				2: Globals.existence  *= $LineEdit.text.to_float()
				3: Globals.existence **= $LineEdit.text.to_float()
		3:
			Globals.EternityPts.call(oper, $LineEdit.text.to_float())
		4:
			Globals.Eternities.call(oper, $LineEdit.text.to_float())

func _process(_delta):
	if visible:
		Engine.time_scale = $HSlider.value
		$HSlider/Label.text = "Game speed: ×%s" % Globals.float_to_string($HSlider.value)
