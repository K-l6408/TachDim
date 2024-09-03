extends Control

@onready var TBar : TabBar = %Tabs.get_tab_bar()
var debugMode := false

var tabSymbolLeft  = "⇠\uf085⁈δΞ\uf091\uf0ca\uf1de[!"
var tabSymbolRight = "⇢\uf1de⁉δΞ\uf091\uf0c9\uf0ad]!"

var dimensionSymbols = "Ψδ"
var challengeSymbols = "Ψδ"
var  eternitySymbols = "↑⭻"
var     statsSymbols = "\uf036\uf886\uf0cb"
var   optionsSymbols = "\uf0c7\uf1fc"
var celestialSymbols = "⏣⚴☾𝄽\uF1E0ɸΩ"

func _ready():
	Globals.NotifHandler = $Notifs
	Globals.TDHandler = %Tabs/Dimensions/Tachyons
	Globals.EDHandler = %Tabs/Dimensions/Eternity
	Globals.Automation = %Tabs/Automation
	Globals.Achievemer = %Tabs/Achievements
	Globals.Animater = $AnimationPlayer
	Globals.VisualSett = %Tabs/Options/Visual
	Globals.EUHandler = %"Tabs/Eternity/Eternity Upgrades"
	Globals.OEUHandler = %"Tabs/Eternity/Overcome Eternity"
	Globals.DupHandler = %Tabs/Duplicantes
	
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
	RenderingServer.set_default_clear_color(
		get_theme_stylebox("panel", "Panel").bg_color
	)
	TBar.set_tab_hidden(1, Globals.TachTotal.less(largenum.new(10).pow2self(20)))
	TBar.set_tab_hidden(2, Globals.progress < Globals.Progression.Eternity)
	TBar.set_tab_hidden(3, Globals.progress < Globals.Progression.Eternity)
	TBar.set_tab_hidden(4, Globals.progress < Globals.Progression.Duplicantes)
	
	%Tabs/Dimensions.set_tab_hidden(1, Globals.EDHandler.DimsUnlocked == 0)
	%Tabs/Challenges.set_tab_hidden(
		1, Globals.TachTotal.log10() < Globals.ECUnlocks[0]
	)
	
	$ETint.global_position = TBar.get_tab_rect(3).position + TBar.global_position\
	+ Vector2(-1, 1)
	$ETint.size            = TBar.get_tab_rect(3).size
	$ETint.color           = get_theme_color("font_color", "ButtonEtern")
	$ETint.material.set_shader_parameter(
		"replace", get_theme_stylebox("panel", "TabContainer").bg_color
	)
	
	$DTint.global_position = TBar.get_tab_rect(4).position + TBar.global_position\
	+ Vector2(-1, 1)
	$DTint.size            = TBar.get_tab_rect(4).size
	$DTint.color           = get_theme_color("meow", "DupliButton")
	$DTint.material.set_shader_parameter(
		"replace", get_theme_stylebox("panel", "TabContainer").bg_color
	)
	
	if Input.is_action_just_pressed("Debug"): debugMode = not debugMode
	TBar.set_tab_hidden(TBar.tab_count - 1, not debugMode)
	
	%Resources/Rewind/Button.disabled = \
	%Tabs/Dimensions/Tachyons.rewindNode.disabled
	%Resources/Rewind.visible = \
	%Tabs/Dimensions/Tachyons.rewindNode.visible
	
	%Resources/Eternity.visible = \
	Globals.progress >= GL.Progression.Overcome and \
	(Globals.Challenge == 0 or Globals.Challenge > 15)
	%Resources/Eternity/EternityButton.disabled = \
	not %Tabs/Dimensions/Tachyons.canBigBang
	
	%Resources/EDunlock.visible = \
	Globals.progress >= GL.Progression.Overcome and \
	(Globals.Challenge == 0 or Globals.Challenge > 15) and \
	Globals.EDHandler.DimsUnlocked < 8
	%Resources/EDunlock/EDButton.disabled = true
	
	%Resources/EP.visible = (Globals.progress >= GL.Progression.Eternity)
	%Resources/Challenge.visible = (Globals.progress >= GL.Progression.Eternity)
	%Resources/Dupl.visible = (Globals.progress >= GL.Progression.Duplicantes)
	
	%Resources/Tachyons/Text.text = \
	"[center][font_size=16]%s[/font_size]\nTachyons[/center]" % Globals.Tachyons.to_string()
	%Resources/EP/Text.text = \
	"[center][color=%s][font_size=16]%s[/font_size]\nEternity Points[/color][/center]" % [
		get_theme_color("font_color", "ButtonEtern").to_html(false),
		Globals.EternityPts.to_string()
	]
	%Resources/Dupl/Text.text = \
	"[center][color=%s][font_size=16]%s[/font_size]\nDuplican%ss[/color][/center]" % [
		get_theme_color("meow", "DupliButton").to_html(false),
		Globals.Duplicantes.to_string(), "" if Globals.Duplicantes.less(1) else "te"
	]
	if Globals.Challenge > 15:
		%Resources/Challenge/Text.text = \
		"[center]Current Challenge:\n[font_size=16]EC%s[/font_size][/center]" % \
		Globals.int_to_string(Globals.Challenge - 15)
	elif Globals.Challenge > 0:
		%Resources/Challenge/Text.text = \
		"[center]Current Challenge:\n[font_size=16]C%s[/font_size][/center]" % \
		Globals.int_to_string(Globals.Challenge)
	else:
		%Resources/Challenge/Text.text = \
		"[center]Current Challenge:\n[font_size=16]None[/font_size][/center]"
	
	
	if %Resources/Eternity/EternityButton.disabled:
		%Resources/Eternity/EternityButton.text = "Reach\n%s Tachyons" % (
			largenum.two_to_the(1024) if Globals.Challenge <= 15 else
			Globals.ECTargets[Globals.Challenge - 16]
		).to_string()
	elif Globals.Challenge > 15:
		%Resources/Eternity/EternityButton.text = "Big Bang to\ncomplete the\nchallenge"
	else:
		%Resources/Eternity/EternityButton.text = "Big Bang for\n%s EP\n(%s EP/s)" % [
			%Tabs/Dimensions/Tachyons.epgained().to_string(),
			%Tabs/Dimensions/Tachyons.epgained().divide(Globals.eternTime).to_string()
		]

func rewind(score):
	%Tabs/Dimensions/Tachyons.rewind(score)
