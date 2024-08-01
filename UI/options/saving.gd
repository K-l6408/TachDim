extends Control

var progressTexture := preload("res://images/progress.png")
var currentFile := 1
var saveFilePath :
	get: return "user://save%d.txt" % currentFile

func _ready():
	start()

func start():
	await get_tree().process_frame
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.READ)
	if sf == null: return gameReset()
	currentFile = sf.get_as_text().to_int()
	await get_tree().process_frame
	loadF()

func _process(_delta):
	$HFlowContainer/Autosave.text = "Autosave: %s" % ("ON" if $HFlowContainer/Autosave.button_pressed else "OFF")
	$HFlowContainer/HSlider/Label.text = " \nAutosaves every %d seconds" % $HFlowContainer/HSlider.value

func _on_value_changed(val):
	$Timer.wait_time = val

func autosave():
	if $HFlowContainer/Autosave.button_pressed:
		saveF()

func choose_save(which):
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
		"animation settings" : Globals.VisualSett.save_anim_settings()
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
		DATA["dilation buy limit"] = Globals.Automation.DilLimit
		DATA["dilation limit ignore"] = Globals.Automation.DilIgnore
		DATA["tach gal buy limit"] = Globals.Automation.GalLimit
	
	sf.store_var(DATA)
	sf.close()
	
	var lsf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	lsf.store_string("%d" % currentFile)

func loadF(file : String = saveFilePath):
	var settf := FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.READ)
	if settf != null:
		
		var d = settf.get_var()
		if d != null:
			$HFlowContainer/Autosave.button_pressed = d["autosaving"]
			$HFlowContainer/HSlider.value = d["autosave interval"]
			Globals.display = d["notation"] as GL.DisplayMode
			Globals.VisualSett.load_anim_settings(d["animation settings"])
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
	
	if sf == null:						return
	if sf.get_line() != "TachDimSave":	return
	
	Globals.progress = sf.get_8()
	Globals.Challenge = sf.get_8()
	
	var DATA = sf.get_var()
	if not DATA is Dictionary:
		Globals.progress = 0
		Globals.Challenge = 0
		return
	
	Globals.existence = DATA["time played"]
	# idle progress. uses "last time" to check.
	
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
		
		Globals.fastestEtern.time				 = DATA["fastest eternity"].time
		Globals.fastestEtern.epgain    .from_bytes(DATA["fastest eternity"].epgain)
		Globals.fastestEtern.eternities.from_bytes(DATA["fastest eternity"].epgain)
		
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
		Globals.Automation.DilLimit = DATA["dilation buy limit"]
		Globals.Automation.DilIgnore = DATA["dilation limit ignore"]
		Globals.Automation.GalLimit = DATA["tach gal buy limit"]

func gameReset():
	Globals.progress = Globals.Progression.None
	Globals.Tachyons  = largenum.new(10)
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
	Globals.fastestEtern = {
		time       = -1,
		epgain     = largenum.new(1),
		eternities = largenum.new(1)
	}
	Globals.EternityPts = largenum.new(0)
	Globals.Eternities = largenum.new(0)
	Globals.Challenge = 0
	Globals.CompletedChallenges = 0
	Globals.EUHandler.Bought = 0
	Globals.Automation.TSUpgrades = 0
	Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]

