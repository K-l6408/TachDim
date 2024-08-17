extends Control

var progressTexture := preload("res://images/progress.png")
var currentFile := 1
var saveFilePath :
	get: return "user://save%d.txt" % currentFile
var idleTimeSpent = 0

func _ready():
	start()
	match OS.get_name():
		"Windows", "UWP":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to %APPDATA%\\Godot\\app_userdata" + \
			"\\Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile
		"Linux", "X11", "FreeBSD", "NetBSD", "BSD":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to ~/.local/share/godot/app_userdata" +\
			"/Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile

func start():
	await get_tree().process_frame
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.READ)
	if sf == null: return gameReset()
	currentFile = sf.get_as_text().to_int()
	await get_tree().process_frame
	loadF()

func _process(delta):
	$HFlowContainer/Autosave.text = "Autosave: %s" % ("ON" if $HFlowContainer/Autosave.button_pressed else "OFF")
	$HFlowContainer/HSlider/Label.text = "\n\nAutosaves every %s" % \
	Globals.format_time($HFlowContainer/HSlider.value)
	$HFlowContainer/Idle.text = "Idle progress: %s" % ("ON" if $HFlowContainer/Idle.button_pressed else "OFF")
	$HFlowContainer/Sidler/Label.text = "\nTake %s at most to calculate\nidle progress" % \
	Globals.format_time($HFlowContainer/Sidler.value)
	$HFlowContainer/Idle.visible = Globals.challengeCompleted(15)
	$HFlowContainer/Sidler.visible = Globals.challengeCompleted(15)
	
	if $Idle.visible:
		idleTimeSpent += delta
		$Idle/ColorRect/Panel/RichTextLabel.text = "[center]\n[font_size=20]%s\n%s / %s %s\n(%s / %s %s)" % [
			"Calculating idle progress…",
			Globals.format_time(idleTimeSpent), Globals.format_time($IdleTimer.wait_time),
			"processed",
			Globals.format_time(idleTimeSpent / Engine.time_scale),
			Globals.format_time($IdleTimer.wait_time / Engine.time_scale), "real time"
		]
		$Idle/ColorRect/Panel/ProgressBar.value = idleTimeSpent / $IdleTimer.wait_time
		$Idle/ColorRect/Panel/ProgressBar/Label.text = Globals.percent_to_string(idleTimeSpent / $IdleTimer.wait_time)

func _on_value_changed(val):
	$SaveTimer.wait_time = val

func autosave():
	if $HFlowContainer/Autosave.button_pressed:
		saveF()

func choose_save(which):
	currentFile = which
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	sf.store_string("%d" % which)
	saveF()

func choose_load(which):
	currentFile = which
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	sf.store_string("%d" % which)
	loadF()

func openDialog():
	for f in 5:
		var sf = FileAccess.open("user://save%d.txt" % (f + 1), FileAccess.READ)
		if sf == null: continue
		if sf.get_line() != "TachDimSave": continue
		get_node("Files/%d/Progress" % (f+1)).texture.region.position.x = sf.get_8() * 32
		sf.get_8()
		var D = sf.get_var()
		if D is Dictionary:
			get_node("Files/%d/Tachyons" % (f+1)).text = \
			"%s Tachyons" % largenum.new().from_bytes(D["tachyons"]).to_string()
		else:
			get_node("Files/%d/Tachyons" % (f+1)).text = "Outdated or corrupted file"

func saveF(file : String = saveFilePath):
	var settf := FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.WRITE)
	
	settf.store_var({
		"autosaving" : $HFlowContainer/Autosave.button_pressed,
		"autosave interval" : int($HFlowContainer/HSlider.value),
		"notation" : Globals.display,
		"animation settings" : Globals.VisualSett.save_anim_settings(),
		"idle progress" : $HFlowContainer/Idle.button_pressed,
		"idle progress max time" : int($HFlowContainer/Sidler.value)
	})
	
	settf.close()
	var sf := FileAccess.open(file, FileAccess.WRITE)
	sf.store_line("TachDimSave")
	
	sf.store_8(Globals.progress)
	sf.store_8(Globals.Challenge)
	
	var DATA : Dictionary = {
		"time played": Globals.existence,
		"last time" : Time.get_unix_time_from_system() as int,
		"tachyons" : Globals.Tachyons.to_bytes(),
		"total tachyons" : Globals.TachTotal.to_bytes(),
		"achievements" : Globals.Achievemer.unlocked,
		"tach dim amounts" : [
			Globals.TDHandler.DimAmount[0].to_bytes(),
			Globals.TDHandler.DimAmount[1].to_bytes(),
			Globals.TDHandler.DimAmount[2].to_bytes(),
			Globals.TDHandler.DimAmount[3].to_bytes(),
			Globals.TDHandler.DimAmount[4].to_bytes(),
			Globals.TDHandler.DimAmount[5].to_bytes(),
			Globals.TDHandler.DimAmount[6].to_bytes(),
			Globals.TDHandler.DimAmount[7].to_bytes()
		],
		"tach dim purchases" : Globals.TDHandler.DimPurchase,
		"tach dim costs" : [
			Globals.TDHandler.DimCost[0].to_bytes(),
			Globals.TDHandler.DimCost[1].to_bytes(),
			Globals.TDHandler.DimCost[2].to_bytes(),
			Globals.TDHandler.DimCost[3].to_bytes(),
			Globals.TDHandler.DimCost[4].to_bytes(),
			Globals.TDHandler.DimCost[5].to_bytes(),
			Globals.TDHandler.DimCost[6].to_bytes(),
			Globals.TDHandler.DimCost[7].to_bytes()
		],
		"timespeed amount" : Globals.TDHandler.TSpeedCount,
		"timespeed cost" : Globals.TDHandler.TSpeedCost.to_bytes(),
		"rewind multiplier" : Globals.TDHandler.RewindMult.to_bytes(),
		"time dilation" : Globals.TDilation,
		"tachyon galaxies" : Globals.TGalaxies,
		"unlocked autobuyers" : (Globals.Automation.Unlocked),
		"tach dim buyers modes" : Globals.Automation.TDModes,
		"tach dim buyers enabled" : Globals.Automation.TDEnabl
	}
	
	if Globals.progress >= GL.Progression.Eternity:
		DATA["eternity points"] = Globals.EternityPts.to_bytes()
		DATA["eternities"] = Globals.Eternities.to_bytes()
		DATA["fastest eternity"] = {
			time = Globals.fastestEtern.time,
			epgain = Globals.fastestEtern.epgain.to_bytes(),
			eternities = Globals.fastestEtern.eternities.to_bytes()
		}
		DATA["time in eternity"] = Globals.eternTime
		if Globals.Challenge == 10:
			DATA["c10 power"] = Globals.TDHandler.C10Power
		DATA["completed challenges"] = Globals.CompletedChallenges
		DATA["bought eternity upgrades"] = Globals.EUHandler.Bought
		DATA["tach dim buyers upgrades"] = Globals.Automation.TDUpgrades
		DATA["timespeed buyer upgrades"] = Globals.Automation.TSUpgrades
		DATA["dilation buyer upgrades"] = Globals.Automation.DilUpgrades
		DATA["tach gal buyer upgrades"] = Globals.Automation.GalUpgrades
		DATA["autobanger upgrades"] = Globals.Automation.BangUpgrades
		DATA["dilation buyer enabled"] = \
		Globals.Automation.get_node("Auto/Buyers/Dilation/Enabled").button_pressed
		DATA["tach gal buyer enabled"] = \
		Globals.Automation.get_node("Auto/Buyers/Galaxy/Enabled").button_pressed
		DATA["autobanger enabled"] = \
		Globals.Automation.get_node("Auto/Buyers/BigBang/Enabled").button_pressed
		DATA["rewind buyer int. updrades"] = Globals.Automation.RewdAQups
		DATA["rewind buyer acc. updrades"] = Globals.Automation.RewdUpgrades
		DATA["rewind buyer objective"] = \
		Globals.Automation.get_node("Auto/Buyers/Rewind/Objective").value
		DATA["dilation buy limit"] = Globals.Automation.DilLimit
		DATA["dilation limit ignore"] = Globals.Automation.DilIgnore
		DATA["tach gal buy limit"] = Globals.Automation.GalLimit
		DATA["timespeed buyer mode"] = \
		Globals.Automation.get_node("Auto/Buyers/TimeSpeed/Mode").button_pressed
		DATA["big bang buyer amount"] = Globals.Automation.get_node("Auto/Buyers/BigBang/Amount").text
		
		DATA["ep multiplier buys"] = Globals.EUHandler.EPMultBought
		
		if Globals.EU12Timer != null:
			DATA["eu12 timer"] = Globals.EU12Timer.time_left
		else:
			DATA["eu12 timer"] = 0
		
		DATA["last 10 eternities"] = []
		for e in Globals.last10etern:
			DATA["last 10 eternities"].append(e.to_dict())
		
		DATA["challenge times"] = Globals.challengeTimes
	
	if Globals.progress >= GL.Progression.Overcome:
		DATA["bought overcome upgrades"] = Globals.OEUHandler.Bought
		DATA["tmsp scale bought"] = Globals.OEUHandler.TSpScBought
		DATA["tdim scale bought"] = Globals.OEUHandler.TDmScBought
		DATA["passive ep bought"] = Globals.OEUHandler.PasEPBought
	
	sf.store_var(DATA)
	sf.close()
	
	var lsf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	lsf.store_string("%d" % currentFile)

func loadF(file : String = saveFilePath):
	var pause = get_tree().paused
	get_tree().paused = true
	$CanvasLayer.visible = true
	
	var settf := FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.READ)
	if settf != null:
		
		var d = settf.get_var()
		if d != null:
			$HFlowContainer/Autosave.button_pressed = d["autosaving"]
			$HFlowContainer/HSlider.value = d["autosave interval"]
			Globals.display = d["notation"] as GL.DisplayMode
			Globals.VisualSett.load_anim_settings(d["animation settings"])
			if d.has("idle progress"):
				$HFlowContainer/Idle.button_pressed = d["idle progress"]
			if d.has("idle progress max time"):
				$HFlowContainer/Sidler.value = d["idle progress max time"]
		else:
			settf = FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.READ)
			var autosavesettings = settf.get_8()
			$HFlowContainer/Autosave.button_pressed = autosavesettings & 128
			$HFlowContainer/HSlider.value = (autosavesettings & 127) * 30
			Globals.display = settf.get_8() as Globals.DisplayMode
			Globals.VisualSett.load_anim_settings(settf.get_8())
			settf.close()
	
	var sf := FileAccess.open(file, FileAccess.READ)
	
	gameReset()
	
	if sf == null:
		get_tree().paused = pause
		$CanvasLayer.visible = false
		return
	if sf.get_line() != "TachDimSave":	return
	
	Globals.progress = sf.get_8() as GL.Progression
	Globals.Challenge = sf.get_8()
	
	var DATA = sf.get_var()
	if not DATA is Dictionary:
		Globals.progress = GL.Progression.None
		Globals.Challenge = 0
		return
	
	Globals.existence = DATA["time played"]
	
	Globals.Tachyons.from_bytes(DATA["tachyons"])
	Globals.TachTotal.from_bytes(DATA["total tachyons"])
	
	Globals.Achievemer.unlocked = DATA["achievements"]
	for i in 8:
		Globals.TDHandler.DimAmount[i].from_bytes(DATA["tach dim amounts"][i])
		Globals.TDHandler.DimCost[i].from_bytes(DATA["tach dim costs"][i])
		Globals.TDHandler.DimPurchase[i] = DATA["tach dim purchases"][i]
	
	Globals.TDHandler.TSpeedCount = DATA["timespeed amount"]
	Globals.TDHandler.TSpeedCost.from_bytes(DATA["timespeed cost"])
	Globals.TDHandler.RewindMult.from_bytes(DATA["rewind multiplier"])
	
	Globals.TDilation = DATA["time dilation"]
	Globals.TGalaxies = DATA["tachyon galaxies"]
	
	Globals.Automation.Unlocked = DATA["unlocked autobuyers"]
	Globals.Automation.TDModes = DATA["tach dim buyers modes"]
	Globals.Automation.TDEnabl = DATA["tach dim buyers enabled"]
	
	if Globals.progress >= GL.Progression.Eternity:
		Globals.EternityPts.from_bytes(DATA["eternity points"])
		Globals.Eternities.from_bytes(DATA["eternities"])
		if DATA.has("time in eternity"):
			Globals.eternTime = DATA["time in eternity"]
		
		if DATA.has("fastest eternity"):
			if DATA["fastest eternity"] is Dictionary:
				Globals.fastestEtern = Globals.EternityData.from_dict(DATA["fastest eternity"])
			elif DATA["fastest eternity"] is int or DATA["fastest eternity"] is float:
				Globals.fastestEtern.time       = DATA["fastest eternity"]
				Globals.fastestEtern.epgain     = largenum.new(1)
				Globals.fastestEtern.eternities = largenum.new(1)
		
		if Globals.Challenge == 10:
			Globals.TDHandler.C10Power = DATA["c10 power"]
		Globals.CompletedChallenges = DATA["completed challenges"]
		Globals.EUHandler.Bought = DATA["bought eternity upgrades"]
		Globals.Automation.TDUpgrades = DATA["tach dim buyers upgrades"]
		Globals.Automation.TSUpgrades = DATA["timespeed buyer upgrades"]
		Globals.Automation.DilUpgrades = DATA["dilation buyer upgrades"]
		Globals.Automation.GalUpgrades = DATA["tach gal buyer upgrades"]
		Globals.Automation.BangUpgrades = DATA["autobanger upgrades"]
		Globals.Automation.get_node("Auto/Buyers/Dilation/Enabled").button_pressed\
		= DATA["dilation buyer enabled"]
		Globals.Automation.get_node("Auto/Buyers/Galaxy/Enabled").button_pressed\
		= DATA["tach gal buyer enabled"]
		Globals.Automation.get_node("Auto/Buyers/BigBang/Enabled").button_pressed\
		= DATA["autobanger enabled"]
		if DATA.has("rewind buyer objective"):
			Globals.Automation.get_node("Auto/Buyers/Rewind/Objective").value\
			= DATA["rewind buyer objective"]
		if DATA.has("rewind buyer int. updrades"):
			Globals.Automation.RewdAQups = DATA["rewind buyer int. updrades"]
		if DATA.has("rewind buyer acc. updrades"):
			Globals.Automation.RewdUpgrades = DATA["rewind buyer acc. updrades"]
		if DATA.has("timespeed buyer mode"):
			Globals.Automation.get_node("Auto/Buyers/TimeSpeed/Mode").button_pressed\
			= DATA["timespeed buyer mode"]
		if DATA.has("big bang buyer amount"):
			Globals.Automation.get_node("Auto/Buyers/BigBang/Amount").text = DATA["big bang buyer amount"]
			Globals.Automation.update_bigbang_ep(DATA["big bang buyer amount"])
		Globals.Automation.DilLimit = DATA["dilation buy limit"]
		Globals.Automation.DilIgnore = DATA["dilation limit ignore"]
		Globals.Automation.GalLimit = DATA["tach gal buy limit"]
		
		if DATA.has("eu12 timer"):
			Globals.EU12Timer = get_tree().create_timer(DATA["eu12 timer"])
		
		if DATA.has("last 10 eternities"):
			Globals.last10etern = []
			for e in DATA["last 10 eternities"]:
				if Globals.EternityData.from_dict(e) != null:
					Globals.last10etern.append(
						Globals.EternityData.from_dict(e)
					)
		
		if DATA.has("ep multiplier buys"):
			Globals.EUHandler.EPMultBought = DATA["ep multiplier buys"]
		
		var idletime = Time.get_unix_time_from_system() - DATA["last time"]
		if not Globals.Achievemer.is_unlocked(3, 3) and idletime >= 3600 * 6:
			Globals.Achievemer.set_unlocked(3, 3)
		if $HFlowContainer/Idle.button_pressed and Globals.challengeCompleted(15):
			emit_signal("start_idle_progress", idletime)
		
		if DATA.has("challenge times"):
			Globals.challengeTimes = DATA["challenge times"]
	else:
		Globals.eternTime = Globals.existence
	
	if Globals.progress >= GL.Progression.Overcome:
		if DATA.has("bought overcome upgrades"):
			Globals.OEUHandler.Bought = DATA["bought overcome upgrades"]
		
		if DATA.has("tmsp scale bought"):
			Globals.OEUHandler.TSpScBought = DATA["tmsp scale bought"]
		if DATA.has("tdim scale bought"):
			Globals.OEUHandler.TDmScBought = DATA["tdim scale bought"]
		if DATA.has("passive ep bought"):
			Globals.OEUHandler.PasEPBought = DATA["passive ep bought"]
	
	get_tree().paused = pause
	$CanvasLayer.visible = false

func gameReset():
	Globals.progress = Globals.Progression.None
	Globals.existence = 0
	Globals.Tachyons  = largenum.new(10.001)
	Globals.TachTotal = largenum.new(10)
	Globals.Achievemer.unlocked = []
	for i in Globals.Achievemer.MAXROWS:
		Globals.Achievemer.unlocked.append(0)
	for i in 8:
		Globals.TDHandler.DimAmount[i] = largenum.new(0)
		Globals.TDHandler.DimPurchase[i] = 0
		Globals.TDHandler.DimCost[i] = [
			largenum.ten_to_the(1),largenum.ten_to_the( 2),largenum.ten_to_the( 4),largenum.ten_to_the( 6),
			largenum.ten_to_the(9),largenum.ten_to_the(13),largenum.ten_to_the(18),largenum.ten_to_the(24)
		][i]
	Globals.TDHandler.TSpeedCount = 0
	Globals.TDHandler.TSpeedCost = largenum.new(1000)
	Globals.TDHandler.RewindMult = largenum.new(1)
	Globals.TDilation = 0
	Globals.TGalaxies = 0
	Globals.Automation.Unlocked = 0
	Globals.Automation.TDModes = 255
	Globals.Automation.TDEnabl = 511
	Globals.fastestEtern = Globals.EternityData.new(-1, 1, 1)
	Globals.eternTime = 0
	Globals.EternityPts = largenum.new(0)
	Globals.Eternities = largenum.new(0)
	Globals.Challenge = 0
	Globals.CompletedChallenges = 0
	Globals.EUHandler.Bought = 0
	Globals.Automation.TSUpgrades = 0
	Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]
	Globals.Automation.get_node("Auto/Buyers/Rewind/Objective").value = 4
	Globals.EU12Timer = null
	Globals.EUHandler.EPMultBought = 0
	Globals.OEUHandler.Bought = 0
	Globals.OEUHandler.TSpScBought = 0
	Globals.OEUHandler.TDmScBought = 0
	Globals.OEUHandler.PasEPBought = 0
	Globals.challengeTimes = [
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1
	]

func idle(idletime):
	var idlerealtime = $HFlowContainer/Sidler.value
	Engine.time_scale = 1. + max(idletime / idlerealtime, 10)
	$SaveTimer.paused = true
	$IdleTimer.start(idletime)
	$Idle.show()
	idleTimeSpent = 0
	$IdleTimer.connect("timeout", func():
		Engine.time_scale = 1
		$SaveTimer.paused = false
		$Idle.hide()
	)

signal start_idle_progress(time)
