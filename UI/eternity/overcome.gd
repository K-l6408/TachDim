extends Control

func _process(delta):
	$"holy shit".disabled = Globals.Automation.BangUpgrades < 13
	$"holy shit".visible  = Globals.progress < GL.Progression.Overcome

func overcome():
	emit_signal("YEAAAH")
	Globals.progress = GL.Progression.Overcome

signal YEAAAH()
