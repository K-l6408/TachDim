extends Control

var progressTexture := preload("res://images/progress.png")
var currentFile := 1
var saveFilePath :
	get: return "user://save%d.txt" % currentFile
var idleTimeSpent = 0

func _ready():
	match OS.get_name():
		"Windows", "UWP":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to %APPDATA%\\Godot\\app_userdata" + \
			"\\Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile
		"Linux", "X11", "FreeBSD", "NetBSD", "BSD":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to ~/.local/share/godot/app_userdata" +\
			"/Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile
	get_tree().create_timer(0.1).connect("timeout", start)

func start():
	var sf = FileAccess.open("user://lastsave.txt", FileAccess.READ)
	if sf == null: return gameReset()
	choose_load(sf.get_as_text().to_int())

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
		var progress = sf.get_8()
		get_node("Files/%d/Progress" % (f+1)).texture.region.position.x = progress * 32
		sf.get_8()
		var D = sf.get_var()
		if D is Dictionary:
			if progress < Globals.Progression.Eternity:
				get_node("Files/%d/Tachyons" % (f+1)).text = \
				"%s Tachyons" % largenum.new(1).from_bytes(D["tachyons"]).to_string()
			else:
				get_node("Files/%d/Tachyons" % (f+1)).text = \
				"%s Eternity Points" % largenum.new(1).from_bytes(D["eternity points"]).to_string()
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
		"idle progress max time" : int($HFlowContainer/Sidler.value),
		"theme" : Globals.VisualSett.theme_txt,
		"ui scaling" : Globals.VisualSett.get_node("HFlow/Scaling").value,
		"blobflakes" : Globals.VisualSett.get_node("%AnimOptions/Blobs").value
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
			Globals.TDHandler.DimBaseCost[0].to_bytes(),
			Globals.TDHandler.DimBaseCost[1].to_bytes(),
			Globals.TDHandler.DimBaseCost[2].to_bytes(),
			Globals.TDHandler.DimBaseCost[3].to_bytes(),
			Globals.TDHandler.DimBaseCost[4].to_bytes(),
			Globals.TDHandler.DimBaseCost[5].to_bytes(),
			Globals.TDHandler.DimBaseCost[6].to_bytes(),
			Globals.TDHandler.DimBaseCost[7].to_bytes()
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
			currency = Globals.fastestEtern.currency.to_bytes(),
			eternities = Globals.fastestEtern.amount.to_bytes()
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
		
		DATA["eter dim amounts"] = [
			Globals.EDHandler.DimAmount[0].to_bytes(),
			Globals.EDHandler.DimAmount[1].to_bytes(),
			Globals.EDHandler.DimAmount[2].to_bytes(),
			Globals.EDHandler.DimAmount[3].to_bytes(),
			Globals.EDHandler.DimAmount[4].to_bytes(),
			Globals.EDHandler.DimAmount[5].to_bytes(),
			Globals.EDHandler.DimAmount[6].to_bytes(),
			Globals.EDHandler.DimAmount[7].to_bytes()
		]
		DATA["eter dim purchases"] = Globals.EDHandler.DimPurchase
		DATA["eter dims unlocked"] = Globals.EDHandler.DimsUnlocked
		DATA["time shards"] = Globals.EDHandler.TimeShards.to_bytes()
		DATA["free timespeed"] = Globals.EDHandler.FreeTSpeed
		DATA["next timespeed"] = Globals.EDHandler.NextUpgrade.to_bytes()
		DATA["TTIE"] = Globals.TDHandler.topTachyonsInEternity.to_bytes()
		
		DATA["dila buyer max time"] = Globals.Automation.get_node("Auto/Buyers/Dilation/BuyMax").value
		DATA["ECcompl"] = Globals.CompletedECs
		DATA["ECtimes"] = Globals.ECTimes
	
	if Globals.progress >= GL.Progression.Duplicantes:
		DATA["duplicantes"]  = Globals.Duplicantes.to_bytes()
		DATA["dupe chance"]  = Globals.DupHandler.chance
		DATA["dupe interv"]  = Globals.DupHandler.intervUpgrades
		DATA["dupe limit"]   = Globals.DupHandler.limitUpgrades
		DATA["dupe max gal"] = Globals.DupHandler.maxGalaxies
		DATA["dupe galaxies"]= Globals.DupHandler.dupGalaxies
	
	if Globals.progress >= GL.Progression.Boundlessness:
		DATA["bln progress"] = Globals.progressBL
		
		DATA["bln-es"] = Globals.Boundlessnesses.to_bytes()
		DATA["bln points"] = Globals.BoundlessPts.to_bytes()
		DATA["top tachyons in bln"] = Globals.TachTotalBL.to_bytes()
		DATA["time in bln"] = Globals.boundTime
		DATA["space theorems"] = [
			Globals.Studies.TCST,
			Globals.Studies.EPST,
			Globals.Studies.BPST
		]
		
		DATA["studies bought"] = ""
		for i in Globals.Studies.purchased:
			DATA["studies bought"] += i + ","
		DATA["studies bought"].trim_suffix(",")
		
		DATA["space dim amounts"] = [
			Globals.SDHandler.DimAmount[0].to_bytes(),
			Globals.SDHandler.DimAmount[1].to_bytes(),
			Globals.SDHandler.DimAmount[2].to_bytes(),
			Globals.SDHandler.DimAmount[3].to_bytes(),
			Globals.SDHandler.DimAmount[4].to_bytes(),
			Globals.SDHandler.DimAmount[5].to_bytes(),
			Globals.SDHandler.DimAmount[6].to_bytes(),
			Globals.SDHandler.DimAmount[7].to_bytes()
		]
		DATA["space purchases"] = Globals.SDHandler.DimPurchase
		DATA["boundless power"] = Globals.SDHandler.BoundlessPower.to_bytes()
		DATA["fastest boundlessness"] = Globals.fastestBLess.to_dict()
		
		DATA["last 10 bln"] = []
		for i in Globals.last10bless:
			DATA["last 10 bln"].append(i.to_dict())
	
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
			if d.has("theme"):
				Globals.VisualSett.change_theme(d["theme"])
			if d.has("ui scaling"):
				Globals.VisualSett.get_node("HFlow/Scaling").value = d["ui scaling"]
				Globals.VisualSett.change_ui_scaling(true)
			if d.has("blobflakes"):
				Globals.VisualSett.get_node("%AnimOptions/Blobs").value = \
				d["blobflakes"]
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
		Globals.TDHandler.DimBaseCost[i].from_bytes(DATA["tach dim costs"][i])
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
				Globals.fastestEtern = Globals.PrestigeData.from_dict(DATA["fastest eternity"])
			elif DATA["fastest eternity"] is int or DATA["fastest eternity"] is float:
				Globals.fastestEtern.time       = DATA["fastest eternity"]
				Globals.fastestEtern.currency   = largenum.new(1)
				Globals.fastestEtern.amount     = largenum.new(1)
		
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
				if Globals.PrestigeData.from_dict(e) != null:
					Globals.last10etern.append(
						Globals.PrestigeData.from_dict(e)
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
		if DATA.has("bln progress"):
			Globals.progressBL = DATA["bln progress"]
		
		if DATA.has("bought overcome upgrades"):
			Globals.OEUHandler.Bought = DATA["bought overcome upgrades"]
		
		if DATA.has("tmsp scale bought"):
			Globals.OEUHandler.TSpScBought = DATA["tmsp scale bought"]
		if DATA.has("tdim scale bought"):
			Globals.OEUHandler.TDmScBought = DATA["tdim scale bought"]
		if DATA.has("passive ep bought"):
			Globals.OEUHandler.PasEPBought = DATA["passive ep bought"]
		
		if DATA.has("eter dim amounts"):
			for i in 8:
				Globals.EDHandler.DimAmount[i].from_bytes(DATA["eter dim amounts"][i])
				Globals.EDHandler.DimPurchase[i] = DATA["eter dim purchases"][i]
			Globals.EDHandler.DimsUnlocked = DATA["eter dims unlocked"]
			Globals.EDHandler.TimeShards.from_bytes(DATA["time shards"])
			Globals.EDHandler.FreeTSpeed = DATA["free timespeed"]
			Globals.EDHandler.NextUpgrade.from_bytes(DATA["next timespeed"])
		
		if DATA.has("TTIE"):
			Globals.TDHandler.topTachyonsInEternity.from_bytes(DATA["TTIE"])
		
		if DATA.has("dila buyer max time"):
			Globals.Automation.get_node("Auto/Buyers/Dilation/BuyMax").value = \
			DATA["dila buyer max time"]
		
		if DATA.has("ECcompl"):
			Globals.CompletedECs = DATA["ECcompl"]
			Globals.ECTimes = DATA["ECtimes"]
			while Globals.ECTimes.size() < 7:
				Globals.ECTimes.append(-1)
	
	if Globals.progress >= GL.Progression.Duplicantes:
		Globals.Duplicantes.from_bytes(DATA["duplicantes"])
		Globals.DupHandler.chance = DATA["dupe chance"]
		Globals.DupHandler.intervUpgrades = DATA["dupe interv"]
		Globals.DupHandler.limitUpgrades = DATA["dupe limit"]
		if DATA.has("dupe galaxies"):
			Globals.DupHandler.maxGalaxies = DATA["dupe max gal"]
			Globals.DupHandler.dupGalaxies = DATA["dupe galaxies"]
	
	if Globals.progress >= GL.Progression.Boundlessness:
		Globals.Boundlessnesses.from_bytes(DATA["bln-es"])
		Globals.BoundlessPts.from_bytes(DATA["bln points"])
		Globals.TachTotalBL.from_bytes(DATA["top tachyons in bln"])
		Globals.boundTime = DATA["time in bln"]
		Globals.Studies.TCST = DATA["space theorems"][0]
		Globals.Studies.EPST = DATA["space theorems"][1]
		Globals.Studies.BPST = DATA["space theorems"][2]
		Globals.Studies.respec()
		for i in DATA["studies bought"].split(","):
			Globals.Studies.buy_study(i)
		for i in 8:
			Globals.SDHandler.DimAmount[i].from_bytes(DATA["space dim amounts"][i])
			Globals.SDHandler.DimPurchase[i] = DATA["space purchases"][i]
		
		Globals.SDHandler.BoundlessPower.from_bytes(DATA["boundless power"])
		
		if DATA.has("fastest boundlessness"):
			Globals.fastestBLess = \
			Globals.PrestigeData.from_dict(DATA["fastest boundlessness"])
		if DATA.has("last 10 bln"):
			Globals.last10bless = []
			for i in DATA["last 10 bln"]:
				Globals.last10bless.append(Globals.PrestigeData.from_dict(i))
	else:
		Globals.progressBL = Globals.progress
		Globals.boundTime = Globals.existence
		Globals.TachTotalBL.from_bytes(DATA["total tachyons"])
	
	Globals.TDHandler.updateTSpeed()
	get_tree().paused = pause
	$CanvasLayer.visible = false

func gameReset():
	Globals.progress  = Globals.Progression.None
	Globals.existence = 0
	Globals.Tachyons  = largenum.ten_to_the(1)
	Globals.TachTotal = largenum.ten_to_the(1)
	Globals.Achievemer.unlocked = []
	for i in Globals.Achievemer.MAXROWS:
		Globals.Achievemer.unlocked.append(0)
	for i in 8:
		Globals.TDHandler.DimAmount[i]   = largenum.new(0)
		Globals.TDHandler.DimPurchase[i] = 0
		Globals.TDHandler.DimBaseCost[i] = [
			largenum.ten_to_the( 1),largenum.ten_to_the( 2),largenum.ten_to_the( 4),
			largenum.ten_to_the( 6),largenum.ten_to_the( 9),largenum.ten_to_the(13),
			largenum.ten_to_the(18),largenum.ten_to_the(24)
		][i]
	Globals.TDHandler.TSpeedCount = 0
	Globals.TDHandler.TSpeedCost  = largenum.new(1000)
	Globals.TDHandler.RewindMult  = largenum.new(1)
	Globals.TDilation = 0
	Globals.TGalaxies = 0
	Globals.TDHandler.updateTSpeed()
	Globals.Automation.Unlocked = 0
	Globals.Automation.TDModes  = 255
	Globals.Automation.TDEnabl  = 511
	Globals.fastestEtern = Globals.PrestigeData.new(-1, 1, 1)
	Globals.eternTime   = 0
	Globals.EternityPts = largenum.new(0)
	Globals.Eternities  = largenum.new(0)
	Globals.Challenge   = 0
	Globals.CompletedChallenges   = 0
	Globals.EUHandler.Bought      = 0
	Globals.Automation.TSUpgrades = 0
	Globals.Automation.TDUpgrades = [0,0,0,0,0,0,0,0]
	Globals.Automation.get_node("Auto/Buyers/Rewind/Objective").value = 4
	Globals.EU12Timer = null
	Globals.EUHandler.EPMultBought = 0
	Globals.OEUHandler.Bought      = 0
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
	Globals.CompletedECs = 0
	Globals.ECTimes      = [
		-1, -1, -1,
		-1, -1, -1,
		-1
	]
	Globals.Duplicantes  = largenum.new(0)
	Globals.DupHandler.chance = 1
	Globals.DupHandler.intervUpgrades = 0
	Globals.DupHandler.limitUpgrades  = 0
	Globals.DupHandler.maxGalaxies    = 0
	Globals.DupHandler.dupGalaxies    = 0
	Globals.Boundlessnesses = largenum.new(0)
	Globals.BoundlessPts = largenum.new(0)
	Globals.TachTotalBL  = Globals.TachTotal
	Globals.boundTime    = 0
	Globals.Studies.TCST = 0
	Globals.Studies.EPST = 0
	Globals.Studies.BPST = 0
	Globals.Studies.respec()
	for i in 8:
		Globals.SDHandler.DimAmount[i] = largenum.new(0)
		Globals.SDHandler.DimPurchase[i] = 0
	Globals.SDHandler.BoundlessPower = largenum.new(0)
	

func idle(idletime):
	var idlerealtime = $HFlowContainer/Sidler.value
	Engine.time_scale = max(idletime / idlerealtime, 10)
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
