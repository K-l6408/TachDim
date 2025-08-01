extends Control

var progressTexture := preload("res://images/progress.png")
var currentFile := 1
var saveFilePath :
	get: return "user://save%d.txt" % currentFile
var idleTimeSpent = 0
const MAX_FILE_NUMBER = 10

func _ready():
	match OS.get_name():
		"Windows", "UWP":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to %APPDATA%\\Godot\\app_userdata" + \
			"\\Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile
		"Linux", "X11", "FreeBSD", "NetBSD", "BSD":
			$CanvasLayer/ColorRect/Panel/RichTextLabel.text += "go to ~/.local/share/godot/app_userdata" +\
			"/Tachyon Dimensions, and check the files for \"save%d.txt\"." % currentFile
	get_tree().create_timer(0.1).connect("timeout", start)
	for i in MAX_FILE_NUMBER:
		var j = $"FilesContainer/Files/1"
		if i != 0:
			j = j.duplicate()
			j.get_node("Progress").texture = \
			j.get_node("Progress").texture.duplicate()
			j.name = str(i+1)
			$FilesContainer/Files.add_child(j)
		j.get_node("Button1").connect("pressed", $FilesContainer.hide)
		j.get_node("Button1").connect("pressed", choose_save.bind(i+1))
		j.get_node("Button2").connect("pressed", $FilesContainer.hide)
		j.get_node("Button2").connect("pressed", choose_load.bind(i+1))

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
	
	for i in $FilesContainer/Files.get_children():
		if i is Panel:
			i.get_node("Label").text = "File #%s" % Globals.int_to_string(i.name.to_int())
	
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
	for f in MAX_FILE_NUMBER:
		var sf = FileAccess.open("user://save%d.txt" % (f + 1), FileAccess.READ)
		if sf == null: continue
		if sf.get_line() != "TachDimSave": continue
		var progress = sf.get_8()
		get_node("FilesContainer/Files/%d/Progress" % (f+1)).texture.region.position.x = progress * 32
		sf.get_8()
		var D = sf.get_var()
		if D is Dictionary:
			if progress < Globals.Progression.Permanence:
				get_node("FilesContainer/Files/%d/Tachyons" % (f+1)).text = \
				"%s Tachyons" % largenum.new(1).from_bytes(D["tachyons"]).to_string()
			else:
				get_node("FilesContainer/Files/%d/Tachyons" % (f+1)).text = \
				"%s Permanence Points" % largenum.new(1).from_bytes(D["eternity points"]).to_string()
		else:
			get_node("FilesContainer/Files/%d/Tachyons" % (f+1)).text = "Outdated or corrupted file"

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
		"tachyons" : Currencies.Tachyons._save(),
		"total tachyons" : Globals.TachTotal.to_bytes(),
		"achievements" : Globals.Achievemer.unlocked,
		"tach dim amounts" : [
			TachyonDims.DimAmount[0].to_bytes(),
			TachyonDims.DimAmount[1].to_bytes(),
			TachyonDims.DimAmount[2].to_bytes(),
			TachyonDims.DimAmount[3].to_bytes(),
			TachyonDims.DimAmount[4].to_bytes(),
			TachyonDims.DimAmount[5].to_bytes(),
			TachyonDims.DimAmount[6].to_bytes(),
			TachyonDims.DimAmount[7].to_bytes()
		],
		"tach dim purchases" : TachyonDims.DimPurchase,
		"timespeed amount" : TachyonDims.TSpeedCount,
		"rewind multiplier" : TachyonDims.RewindMult.to_bytes(),
		"time dilation" : TachyonDims.TDilation,
		"tachyon galaxies" : TachyonDims.TGalaxies,
		"unlocked autobuyers" : Autobuyers.NormUnlocked,
		"tach dim buyers modes" : Autobuyers.NormModes,
		"tach dim buyers enabled" : Autobuyers.NormEnabled
	}
	
	if Globals.progress >= GL.Progression.Permanence:
		DATA["eternity points"] = Currencies.PermanencePts._save()
		DATA["eternities"] = Currencies.Permanences._save()
		DATA["fastest eternity"] = {
			time = Globals.fastestEtern.time,
			currency = Globals.fastestEtern.currency.to_bytes(),
			eternities = Globals.fastestEtern.amount.to_bytes()
		}
		DATA["time in eternity"] = Globals.eternTime
		if Globals.Challenge == 10:
			DATA["c10 power"] = TachyonDims.C10Power
		DATA["completed challenges"] = Globals.CompletedChallenges
		DATA["bought eternity upgrades"] = Permanence.BoughtUpgrades
		DATA["tach dim buyers upgrades"] = Autobuyers.NormUpgrades
		DATA["dilation buyer upgrades"] = Autobuyers.DilUpgrades
		DATA["tach gal buyer upgrades"] = Autobuyers.GalUpgrades
		DATA["autobanger upgrades"] = Autobuyers.BangUpgrades
		DATA["rewind buyer int. updrades"] = Autobuyers.RewdAQups
		DATA["rewind buyer acc. updrades"] = Autobuyers.RewdUpgrades
		DATA["rewind buyer objective"] = Autobuyers.RewindObjective
		DATA["dilation buy limit"] = Autobuyers.DilLimit
		DATA["tach gal buy limit"] = Autobuyers.GalLimit
		DATA["big bang buyer amount"] = Autobuyers.BigBangObjectStr
		
		DATA["ep multiplier buys"] = Permanence.PPMultBought
		
		if Globals.PU12Timer != null:
			DATA["eu12 timer"] = Globals.PU12Timer.time_left
		else:
			DATA["eu12 timer"] = 0
		
		DATA["last 10 eternities"] = []
		for e in Globals.last10etern:
			DATA["last 10 eternities"].append(e.to_dict())
		
		DATA["challenge times"] = Globals.challengeTimes
	
	if Globals.progress >= GL.Progression.Overcome:
		DATA["bought overcome upgrades"] = Permanence.OvercomeUpgrades
		DATA["tmsp scale bought"] = Permanence.TSpScBought
		DATA["tdim scale bought"] = Permanence.TDmScBought
		DATA["passive ep bought"] = Permanence.PasPPBought
		
		DATA["eter dim amounts"] = [
			PermaDims.DimAmount[0].to_bytes(),
			PermaDims.DimAmount[1].to_bytes(),
			PermaDims.DimAmount[2].to_bytes(),
			PermaDims.DimAmount[3].to_bytes(),
			PermaDims.DimAmount[4].to_bytes(),
			PermaDims.DimAmount[5].to_bytes(),
			PermaDims.DimAmount[6].to_bytes(),
			PermaDims.DimAmount[7].to_bytes()
		]
		DATA["eter dim purchases"] = PermaDims.DimPurchase
		DATA["eter dims unlocked"] = PermaDims.DimsUnlocked
		DATA["time shards"] = PermaDims.TimeShards.to_bytes()
		DATA["free timespeed"] = PermaDims.FreeTSpeed
		DATA["next timespeed"] = PermaDims.NextUpgrade.to_bytes()
		DATA["TTIE"] = TachyonDims.topTachyonsInPermanence.to_bytes()
		
		DATA["dila buyer max time"] = Autobuyers.DilaTimeOverride
		DATA["ECcompl"] = Globals.CompletedPCs
		DATA["ECtimes"] = Globals.PCTimes
	
	if Globals.progress >= GL.Progression.Duplicantes:
		DATA["duplicantes"]  = Currencies.Duplicantes.AMOUNT.to_bytes()
		DATA["dupe chance"]  = Duplicantes.chance
		DATA["dupe interv"]  = Duplicantes.intervUpgrades
		DATA["dupe limit"]   = Duplicantes.limitUpgrades
		DATA["dupe max gal"] = Duplicantes.maxGalaxies
		DATA["dupe galaxies"]= Duplicantes.dupGalaxies
	
	if Globals.progress >= GL.Progression.Transcendence:
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
		
		DATA["big bang buyer mode"] = Autobuyers.BigBangMode
		
		DATA["tgal buyer max time"] = Autobuyers.GalaTimeOverride
	
	sf.store_var(DATA)
	sf.close()
	
	var lsf = FileAccess.open("user://lastsave.txt", FileAccess.WRITE)
	lsf.store_string("%d" % currentFile)

func loadF(file : String = saveFilePath):
	get_tree().paused = true
	$CanvasLayer.visible = true
	
	gameReset()
	
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
	
	if sf == null:
		get_tree().paused = false
		$CanvasLayer.visible = false
		return
	if sf.get_line() != "TachDimSave":	return
	
	Globals.progress = sf.get_8() as GL.Progression
	Globals.Challenge = sf.get_8()
	
	var DATA = sf.get_var()
	if not DATA is Dictionary:
		Globals.progress = GL.Progression.None
		Globals.Challenge = 0
		get_tree().paused = false
		$CanvasLayer.visible = false
		return
	
	Globals.existence = DATA["time played"]
	
	Currencies.Tachyons._load(DATA["tachyons"])
	Globals.TachTotal.from_bytes(DATA["total tachyons"])
	
	Globals.Achievemer.unlocked = DATA["achievements"]
	for i in 8:
		TachyonDims.DimAmount[i].from_bytes(DATA["tach dim amounts"][i])
		TachyonDims.DimPurchase[i] = DATA["tach dim purchases"][i]
	
	TachyonDims.TSpeedCount = DATA["timespeed amount"]
	TachyonDims.RewindMult.from_bytes(DATA["rewind multiplier"])
	
	TachyonDims.TDilation = DATA["time dilation"]
	TachyonDims.TGalaxies = DATA["tachyon galaxies"]
	
	Autobuyers.NormUnlocked = DATA["unlocked autobuyers"]
	Autobuyers.NormModes    = DATA["tach dim buyers modes"]
	Autobuyers.NormEnabled  = DATA["tach dim buyers enabled"]
	
	if Globals.progress >= GL.Progression.Permanence:
		Currencies.PermanencePts._load(DATA["eternity points"])
		Currencies.Permanences  ._load(DATA["eternities"])
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
			TachyonDims.C10Power = DATA["c10 power"]
		Globals.CompletedChallenges = DATA["completed challenges"]
		Permanence.BoughtUpgrades = DATA["bought eternity upgrades"]
		Autobuyers.NormUpgrades = DATA["tach dim buyers upgrades"]
		Autobuyers.DilUpgrades = DATA["dilation buyer upgrades"]
		Autobuyers.GalUpgrades = DATA["tach gal buyer upgrades"]
		Autobuyers.BangUpgrades = DATA["autobanger upgrades"]
		if DATA.has("rewind buyer objective"):
			Autobuyers.RewindObjective\
			= DATA["rewind buyer objective"]
		if DATA.has("rewind buyer int. updrades"):
			Autobuyers.RewdAQups = DATA["rewind buyer int. updrades"]
		if DATA.has("rewind buyer acc. updrades"):
			Autobuyers.RewdUpgrades = DATA["rewind buyer acc. updrades"]
		if DATA.has("big bang buyer amount"):
			Autobuyers.BigBangObjectStr = DATA["big bang buyer amount"]
			Autobuyers.update_bigbang_pp( DATA["big bang buyer amount"] )
		Autobuyers.DilLimit  = DATA["dilation buy limit"]
		Autobuyers.GalLimit  = DATA["tach gal buy limit"]
		
		#if DATA.has("eu12 timer"):
			#Globals.EU12Timer = get_tree().create_timer(DATA["eu12 timer"])
		
		if DATA.has("last 10 eternities"):
			Globals.last10etern = []
			for e in DATA["last 10 eternities"]:
				if Globals.PrestigeData.from_dict(e) != null:
					Globals.last10etern.append(
						Globals.PrestigeData.from_dict(e)
					)
		
		if DATA.has("ep multiplier buys"):
			Permanence.PPMultBought = DATA["ep multiplier buys"]
		
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
			Permanence.OvercomeUpgrades = DATA["bought overcome upgrades"]
		
		if DATA.has("tmsp scale bought"):
			Permanence.TSpScBought = DATA["tmsp scale bought"]
		if DATA.has("tdim scale bought"):
			Permanence.TDmScBought = DATA["tdim scale bought"]
		if DATA.has("passive ep bought"):
			Permanence.PasPPBought = DATA["passive ep bought"]
		
		if DATA.has("eter dim amounts"):
			for i in 8:
				PermaDims.DimAmount[i].from_bytes(DATA["eter dim amounts"][i])
				PermaDims.DimPurchase[i] = DATA["eter dim purchases"][i]
			PermaDims.DimsUnlocked = DATA["eter dims unlocked"]
			PermaDims.TimeShards.from_bytes(DATA["time shards"])
			PermaDims.FreeTSpeed = DATA["free timespeed"]
			PermaDims.NextUpgrade.from_bytes(DATA["next timespeed"])
		
		if DATA.has("TTIE"):
			TachyonDims.topTachyonsInPermanence.from_bytes(DATA["TTIE"])
		
		if DATA.has("dila buyer max time"):
			Autobuyers.DilaTimeOverride = \
			DATA["dila buyer max time"]
		
		if DATA.has("ECcompl"):
			Globals.CompletedPCs = DATA["ECcompl"]
			Globals.PCTimes = DATA["ECtimes"]
			while Globals.PCTimes.size() < 8:
				Globals.PCTimes.append(-1)
	
	if Globals.progress >= GL.Progression.Duplicantes:
		Currencies.Duplicantes.AMOUNT.from_bytes(DATA["duplicantes"])
		Duplicantes.chance = DATA["dupe chance"]
		Duplicantes.intervUpgrades = DATA["dupe interv"]
		Duplicantes.limitUpgrades = DATA["dupe limit"]
		if DATA.has("dupe galaxies"):
			Duplicantes.maxGalaxies = DATA["dupe max gal"]
			Duplicantes.dupGalaxies = DATA["dupe galaxies"]
	
	if Globals.progress >= GL.Progression.Transcendence:
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
		
		if DATA.has("big bang buyer mode"):
			Autobuyers.BigBangMode = DATA["big bang buyer mode"]
		
		if DATA.has("tgal buyer max time"):
			Autobuyers.GalaTimeOverride = DATA["tgal buyer max time"]
	else:
		Globals.progressBL = Globals.progress
		Globals.boundTime = Globals.existence
		Globals.TachTotalBL.from_bytes(DATA["total tachyons"])
	
	get_tree().paused = false
	$CanvasLayer.visible = false

func gameReset():
	Globals.progress  = Globals.Progression.None
	Globals.existence = 0
	Globals.TachTotal = largenum.ten_to_the(1)
	Globals.Achievemer.unlocked = []
	for i in Globals.Achievemer.MAXROWS:
		Globals.Achievemer.unlocked.append(0)
	for i in 8:
		TachyonDims.DimAmount[i]   = largenum.new(0)
		TachyonDims.DimPurchase[i] = 0
	TachyonDims.topTachyonsInPermanence = largenum.new(0)
	TachyonDims.TSpeedCount = 0
	TachyonDims.RewindMult  = largenum.new(1)
	TachyonDims.TDilation = 0
	TachyonDims.TGalaxies = 0
	Autobuyers.NormUnlocked = 0
	Autobuyers.NormModes    = 255
	Autobuyers.NormEnabled  = 511
	Globals.fastestEtern = Globals.PrestigeData.new(-1, 1, 1)
	Globals.eternTime   = 0
	Globals.Challenge   = 0
	Globals.CompletedChallenges     = 0
	Permanence.BoughtUpgrades       = 0
	Permanence.PPMultBought         = 0
	Autobuyers.NormUpgrades = [0,0,0,0,0,0,0,0,0]
	Autobuyers.RewindObjective = 4
	Permanence.PU12Timer = 0
	Permanence.OvercomeUpgrades = 0
	Permanence.TSpScBought      = 0
	Permanence.TDmScBought      = 0
	Permanence.PasPPBought      = 0
	Globals.challengeTimes = [
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		-1, -1, -1
	]
	Globals.CompletedPCs = 0
	Globals.PCTimes      = [
		-1, -1, -1,
		-1, -1, -1,
		-1
	]
	Currencies.Duplicantes.AMOUNT = largenum.new(0)
	Duplicantes.chance = 1
	Duplicantes.intervUpgrades = 0
	Duplicantes.limitUpgrades  = 0
	Duplicantes.maxGalaxies    = 0
	Duplicantes.dupGalaxies    = 0
	Globals.Boundlessnesses = largenum.new(0)
	Globals.BoundlessPts = largenum.new(0)
	Globals.TachTotalBL  = largenum.new(Globals.TachTotal)
	Globals.boundTime    = 0
	Globals.Studies.TCST = 0
	Globals.Studies.EPST = 0
	Globals.Studies.BPST = 0
	Globals.Studies.respec()
	for i in 8:
		Globals.SDHandler.DimAmount[i] = largenum.new(0)
		Globals.SDHandler.DimPurchase[i] = 0
	Globals.SDHandler.BoundlessPower = largenum.new(0)
	PermaDims.reset()
	
	Currencies.Tachyons.reset()
	Currencies.PermanencePts.reset()
	Currencies.Permanences  .reset()
	for i in Globals.AnimOpt.size():
		Globals.AnimOpt[i] = true

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
