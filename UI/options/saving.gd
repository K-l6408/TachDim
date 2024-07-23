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
	if sf == null: gameReset()
	currentFile = sf.get_as_text().to_int()
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
	if which == currentFile: return
	currentFile = which
	loadF()
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	sf.store_string("%d" % which)

func openDialog():
	for f in 5:
		var sf = FileAccess.open("user://save%d.txt" % (f + 1), FileAccess.READ)
		if sf == null: continue
		if sf.get_line() != "TachDimSave": continue
		sf.get_64()
		sf.get_16()
		get_node("Files/%d/Progress" % (f+1)).texture.region.position.x = sf.get_8() * 32
		get_node("Files/%d/Tachyons" % (f+1)).text = \
		"%s Tachyons" % largenum.new().from_bytes(sf.get_buffer(16)).to_string()

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

func loadF(file : String = saveFilePath):
	var settf := FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.READ)
	
	var d = settf.get_var()
	if d != null:
		$HFlowContainer/Autosave.button_pressed = d["autosaving"]
		$HFlowContainer/HSlider.value = ["autosave interval"]
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
	if sf == null:
		gameReset()
		return
	if sf.get_line() != "TachDimSave": return
	var DATA = sf.get_var()
	if DATA == null: return loadF_OLD(file)
	
	Globals.progress = sf.get_8()
	Globals.Challenge = sf.get_8()
	
	Globals.existence = DATA["time played"]
	
	# online progress. uses "last time" to check.
	
	Globals.Tachyons.from_bytes(DATA["tachyons"])
	Globals.TachTotal.from_bytes(DATA["total tachyons"])
	
	Globals.Achievemer.unlocked = DATA["achievements"]
	for i in 8:
		Globals.TDHandler.DimAmount.from_bytes(DATA["tach dim amounts"][i])
		Globals.TDHandler.DimCost.from_bytes(DATA["tach dim costs"][i])
	
	Globals.TDHandler.DimPurchase = DATA["tach dim purchases"]
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

func loadF_OLD(file : String = saveFilePath):
	var sf := FileAccess.open(file, FileAccess.READ)
	if sf == null:
		gameReset()
		return
	if sf.get_line() != "TachDimSave": return
	
	Globals.existence = sf.get_64()
	sf.get_16() # for when i implement online progress ← NOT WIÐ ÐIS FORMAT YOU AREN'T HAHHAHAHAAHHAHAHAHAHAHAAHAHAA
	
	Globals.progress = sf.get_8() as Globals.Progression
	Globals.Tachyons.from_bytes(sf.get_buffer(16))
	Globals.TachTotal.from_bytes(sf.get_buffer(16))
	Globals.Achievemer.unlocked = sf.get_buffer(Globals.Achievemer.MAXROWS)
	
	for i in 8:
		Globals.TDHandler.DimAmount[i].from_bytes(sf.get_buffer(16))
		Globals.TDHandler.DimPurchase[i] = sf.get_64()
		Globals.TDHandler.DimCost[i].from_bytes(sf.get_buffer(16))
	
	Globals.TDHandler.TSpeedCount = sf.get_64()
	Globals.TDHandler.TSpeedCost.from_bytes(sf.get_buffer(16))
	Globals.TDHandler.RewindMult.from_bytes(sf.get_buffer(16))
	
	Globals.TDilation = sf.get_64()
	Globals.TGalaxies = sf.get_64()
	
	Globals.Automation.Unlocked = sf.get_8()
	Globals.Automation.TDModes = sf.get_8()
	Globals.Automation.TDEnabl = sf.get_8()
	var TSAB = sf.get_8()
	Globals.Automation.TSpeedUnlocked = (TSAB & 1)
	Globals.Automation.get_node("Auto/Buyers/TimeSpeed/Enabled").button_pressed = (TSAB & 2)
	
	if Globals.progress >= GL.Progression.Eternity:
		Globals.EternityPts.from_bytes(sf.get_buffer(16))
		Globals.Eternities.from_bytes(sf.get_buffer(16))
		Globals.Challenge = sf.get_8()
		if Globals.Challenge == 10:
			Globals.TDHandler.C10Power = sf.get_float()
		Globals.CompletedChallenges = sf.get_16()
		Globals.EUHandler.Bought = sf.get_16()
		Globals.Automation.TSUpgrades = sf.get_8()
		Globals.Automation.TDUpgrades = sf.get_buffer(8)
		Globals.Automation.DilUpgrades = sf.get_8()
		Globals.Automation.GalUpgrades = sf.get_8()
		Globals.Automation.BangUpgrades = sf.get_8()
		var k = sf.get_8()
		Globals.Automation.get_node("Auto/Buyers/Dilation/Enabled").button_pressed = (k&1)
		Globals.Automation.get_node("Auto/Buyers/Galaxy/Enabled").button_pressed   = (k&2)
		Globals.Automation.get_node("Auto/Buyers/BigBang/Enabled").button_pressed  = (k&4)
		Globals.Automation.DilLimit  = sf.get_8()
		Globals.Automation.DilIgnore = sf.get_8()
		Globals.Automation.GalLimit  = sf.get_8()
	else:
		Globals.EternityPts = largenum.new(0)
		Globals.Challenge = 0
		Globals.CompletedChallenges = 0
		Globals.EUHandler.Bought = 0
		Globals.Automation.TSUpgrades = 0
		Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]
		Globals.Automation.DilUpgrades = 0
		Globals.Automation.GalUpgrades = 0
		Globals.Automation.BangUpgrades = 0
		Globals.Automation.DilLimit  = -4
		Globals.Automation.DilIgnore = -2
		Globals.Automation.GalLimit  = -2
	sf.close()
	
	Globals.TDHandler.updateTSpeed()

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
	Globals.Automation.TDEnabl = 255
	Globals.Automation.TSpeedUnlocked = false
	Globals.Automation.get_node("Auto/Buyers/TimeSpeed/Enabled").button_pressed = true
	Globals.EternityPts = largenum.new(0)
	Globals.Eternities = largenum.new(0)
	Globals.Challenge = 0
	Globals.CompletedChallenges = 0
	Globals.EUHandler.Bought = 0
	Globals.Automation.TSUpgrades = 0
	Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]

