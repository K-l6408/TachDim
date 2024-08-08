extends Control

@onready var TBar : TabBar = %Tabs.get_tab_bar()
var debugMode := false

var tabSymbolLeft  = "⇠\uf085⁈δ\uf091\uf0ca\uf1de["
var tabSymbolRight = "⇢\uf1de⁉δ\uf091\uf0c9\uf0ad]"

var dimensionSymbols = "Ψ"
var challengeSymbols = "Ψ"
var  eternitySymbols = "↑⭻"
var     statsSymbols = "\uf036\uf886"
var   optionsSymbols = "\uf0c7\uf1fc"
var celestialSymbols = "⏣⚴☾𝄽\uF1E0ɸΩ"

func _ready():
	Globals.NotifHandler = $Notifs
	Globals.TDHandler = %Tabs/Dimensions/Tachyons
	Globals.Automation = %Tabs/Automation
	Globals.Achievemer = %Tabs/Achievements
	Globals.Animater = $AnimationPlayer
	Globals.VisualSett = %Tabs/Options/Visual
	Globals.EUHandler = %"Tabs/Eternity/Eternity Upgrades"
	
	for i in %Tabs.get_child_count():
		TBar.set_tab_title(i, "%s %s %s" % \
		[tabSymbolLeft[i], %Tabs.get_child(i).name, tabSymbolRight[i]])
	for i in %Tabs/Dimensions.get_child_count():
		%Tabs/Dimensions.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[dimensionSymbols[i], %Tabs/Dimensions.get_child(i).name, dimensionSymbols[i]])
	for i in %Tabs/Challenges.get_child_count():
		%Tabs/Challenges.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[challengeSymbols[i], %Tabs/Challenges.get_child(i).name, challengeSymbols[i]])
	for i in %Tabs/Eternity.get_child_count():
		%Tabs/Eternity.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[eternitySymbols[i], %Tabs/Eternity.get_child(i).name, eternitySymbols[i]])
	for i in %Tabs/Statistics.get_child_count():
		%Tabs/Statistics.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[statsSymbols[i], %Tabs/Statistics.get_child(i).name, statsSymbols[i]])
	for i in %Tabs/Options.get_child_count():
		%Tabs/Options.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[optionsSymbols[i], %Tabs/Options.get_child(i).name, optionsSymbols[i]])

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
	"[center][color=%s][font_size=16]%s[/font_size]\nEternity Points[/color][/center]" % \
	[get_theme_color("font_color", "ButtonEtern").to_html(false), Globals.EternityPts.to_string()]
	%Resources/Challenge/Text.text = \
	"[center]Current Challenge:\n[font_size=16]%s[/font_size][/center]" % \
	("C" + Globals.int_to_string(Globals.Challenge) if Globals.Challenge > 0 else "None")

func rewind(score):
	Globals.TDHandler.rewind(score)
