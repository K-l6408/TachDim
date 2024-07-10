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
	
	settf.store_8(128 * int($HFlowContainer/Autosave.button_pressed) + int($HFlowContainer/HSlider.value / 30))
	settf.store_8(Globals.display)
	settf.store_8(Globals.VisualSett.save_anim_settings())
	
	settf.close()
	var sf := FileAccess.open(file, FileAccess.WRITE)
	sf.store_line("TachDimSave")
	sf.store_64(Globals.existence)
	sf.store_16(Time.get_unix_time_from_system() as int)
	
	sf.store_8(Globals.progress)
	sf.store_buffer(Globals.Tachyons.to_bytes())
	sf.store_buffer(Globals.TachTotal.to_bytes())
	sf.store_buffer(Globals.Achievemer.unlocked)
	
	for i in 8:
		sf.store_buffer(Globals.TDHandler.DimAmount[i].to_bytes())
		sf.store_64(Globals.TDHandler.DimPurchase[i])
		sf.store_buffer(Globals.TDHandler.DimCost[i].to_bytes())
	
	sf.store_64(Globals.TDHandler.TSpeedCount)
	sf.store_buffer(Globals.TDHandler.TSpeedCost.to_bytes())
	sf.store_buffer(Globals.TDHandler.RewindMult.to_bytes())
	
	sf.store_64(Globals.TDilation)
	sf.store_64(Globals.TGalaxies)
	
	sf.store_8(Globals.Automation.Unlocked)
	sf.store_8(Globals.Automation.TDModes)
	sf.store_8(Globals.Automation.TDEnabl)
	sf.store_8(
		int(Globals.Automation.TSpeedUnlocked) +
		int(Globals.Automation.get_node("TimeSpeed/Enabled").button_pressed) * 2
	)
	
	if Globals.progress >= GL.Progression.Eternity:
		sf.store_buffer(Globals.EternityPts.to_bytes())
		sf.store_buffer(Globals.Eternities.to_bytes())
		sf.store_8(Globals.Challenge)
		if Globals.Challenge == 10:
			sf.store_float(Globals.TDHandler.C10Power)
		sf.store_16(Globals.CompletedChallenges)
		sf.store_16(Globals.EUHandler.Bought)
		sf.store_8(Globals.Automation.TSUpgrades)
		sf.store_buffer(Globals.Automation.TDUpgrades)
	sf.close()

func loadF(file : String = saveFilePath):
	var settf := FileAccess.open(file.trim_suffix(".txt") + "_settings.txt", FileAccess.READ)
	
	if settf != null:
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
	
	Globals.existence = sf.get_64()
	sf.get_16() # for when i implement online progress
	
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
	Globals.Automation.get_node("TimeSpeed/Enabled").button_pressed = (TSAB & 2)
	
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
	else:
		Globals.EternityPts = largenum.new(0)
		Globals.Challenge = 0
		Globals.CompletedChallenges = 0
		Globals.EUHandler.Bought = 0
		Globals.Automation.TSUpgrades = 0
		Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]
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
			largenum.new(10   ),largenum.new(100   ),largenum.new(10**4 ),largenum.new(10**6),
			largenum.new(10**9),largenum.new(10**13),largenum.new(10**18),largenum.new(10).power(24)
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
	Globals.Automation.get_node("TimeSpeed/Enabled").button_pressed = true
	Globals.EternityPts = largenum.new(0)
	Globals.Eternities = largenum.new(0)
	Globals.Challenge = 0
	Globals.CompletedChallenges = 0
	Globals.EUHandler.Bought = 0
	Globals.Automation.TSUpgrades = 0
	Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]

