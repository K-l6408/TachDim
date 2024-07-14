extends Control

@onready var TBar : TabBar = %Tabs.get_tab_bar()
var debugMode := false

func _ready():
	Globals.NotifHandler = $Notifs
	Globals.TDHandler = %"Tabs/⇠ Dimensions ⇢/Ψ Tachyons Ψ"
	Globals.Automation = %"Tabs/⚙ Automation ⚙"
	Globals.Achievemer = %"Tabs/🏆 Achievements 🏆"
	Globals.Animater = $AnimationPlayer
	Globals.VisualSett = %"Tabs/🔧 Options 🔧/🎨 Visual 🖌"
	Globals.EUHandler = %"Tabs/Δ Eternity Δ/⨹ Eternity Upgrades ⨹"

func _process(_delta):
	$Camera2D.position = get_viewport_rect().size / 2
	TBar.set_tab_hidden(1, Globals.TachTotal.less(largenum.new(10).pow2self(20)))
	TBar.set_tab_hidden(2, Globals.progress < Globals.Progression.Eternity)
	TBar.set_tab_hidden(3, Globals.progress < Globals.Progression.Eternity)
	
	if Input.is_action_just_pressed("Debug"): debugMode = not debugMode
	TBar.set_tab_hidden(TBar.tab_count - 1, not debugMode)
	
	%Resources/Rewind/Button.disabled = \
	Globals.TDHandler.rewindNode.disabled
	%Resources/Rewind.visible = \
	Globals.TDHandler.rewindNode.visible
	
	%Resources/EP.visible = (Globals.progress >= Globals.Progression.Eternity)
	%Resources/Challenge.visible = (Globals.progress >= Globals.Progression.Eternity)
	
	%Resources/Tachyons/Text.text = \
	"[center][font_size=16]%s[/font_size]\nTachyons[/center]" % Globals.Tachyons.to_string()
	%Resources/EP/Text.text = \
	"[center][color=b241e3][font_size=16]%s[/font_size]\nEternity Points[/color][/center]" % \
	Globals.EternityPts.to_string()
	%Resources/Challenge/Text.text = \
	"[center]Current Challenge:\n[font_size=16]%s[/font_size][/center]" % \
	("C" + Globals.int_to_string(Globals.Challenge) if Globals.Challenge > 0 else "None")

func rewind(score):
	Globals.TDHandler.rewind(score)
