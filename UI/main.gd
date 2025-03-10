extends Control

@onready var TBar : TabBar = %Tabs.get_tab_bar()
var debugMode := false

var tabSymbolLeft  = "⇠\uf085⁈δΞ∀\uf091\uf11c\uf0ca\uf1de[!"
var tabSymbolRight = "⇢\uf1de⁉δΞ∀\uf091\uf11c\uf0c9\uf0ad]!"

var  dimensionSymbols = "Ψδ∀"
var  challengeSymbols = "Ψδ∀"
var permanenceSymbols = "↑⭻"
var  boundlessSymbols = "\uf0e8\uf005"
var      statsSymbols = "\uf036\uf162\uf0cb\uf1ec"
var    optionsSymbols = "\uf0c7\uf1fc"
var  celestialSymbols = "⏣⚴☾𝄽\uf1e0ɸ⸸"

func _ready():
	Globals.NotifHandler = $Notifs
	Globals.SDHandler = %Tabs/Dimensions/Space
	Globals.Achievemer = %Tabs/Achievements
	Globals.Animater = $AnimationPlayer
	Globals.VisualSett = %Tabs/Options/Visual
	Globals.DupHandler = %Tabs/Duplicantes
	Globals.Studies = %"Tabs/Transcendence/Space Studies"
	
	for i in %Tabs.get_child_count():
		TBar.set_tab_title(i, "%s %s %s" % \
		[tabSymbolLeft[i], %Tabs.get_child(i).name, tabSymbolRight[i]])
	for i in %Tabs/Dimensions.get_child_count():
		%Tabs/Dimensions.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[dimensionSymbols[i], %Tabs/Dimensions.get_child(i).name, dimensionSymbols[i]])
	for i in %Tabs/Challenges.get_child_count():
		%Tabs/Challenges.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[challengeSymbols[i], %Tabs/Challenges.get_child(i).name, challengeSymbols[i]])
	for i in %Tabs/Permanence.get_child_count():
		%Tabs/Permanence.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[permanenceSymbols[i], %Tabs/Permanence.get_child(i).name, permanenceSymbols[i]])
	for i in %Tabs/Transcendence.get_child_count():
		%Tabs/Transcendence.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[boundlessSymbols[i], %Tabs/Transcendence.get_child(i).name, boundlessSymbols[i]])
	for i in %Tabs/Statistics.get_child_count():
		%Tabs/Statistics.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[statsSymbols[i], %Tabs/Statistics.get_child(i).name, statsSymbols[i]])
	for i in %Tabs/Options.get_child_count():
		%Tabs/Options.get_tab_bar().set_tab_title(i, "%s %s %s" % \
		[optionsSymbols[i], %Tabs/Options.get_child(i).name, optionsSymbols[i]])
	
	%Resources/PDunlock/PDButton.connect("pressed", PermaDims.unlocknewdim)
	%PermanenceButton.connect("pressed", TachyonDims.permanence)

func _process(_delta):
	$Camera2D.position = get_viewport_rect().size / 2
	$Blobrain.position.x = size.x / 2
	$Blobrain.process_material.emission_box_extents.x = \
	size.x / 2
	$Blobrain.visible = (%Tabs/Options/Visual.theme_txt == "Blob")
	$Blobrain.amount = Globals.VisualSett.get_node("%AnimOptions/Blobs").value
	if "BGPanel" in get_theme().get_type_list():
		$Background.theme_type_variation = "BGPanel"
	else:
		$Background.theme_type_variation = ""
	
	$Window.visible = not get_tree().root.has_focus()
	
	TBar.set_tab_hidden(1, Globals.TachTotal.less(largenum.new(10).pow2self(20)))
	TBar.set_tab_hidden(2, Globals.progress < Globals.Progression.Permanence)
	TBar.set_tab_hidden(3, Globals.progress < Globals.Progression.Permanence)
	TBar.set_tab_hidden(4, Globals.progress < Globals.Progression.Duplicantes)
	TBar.set_tab_hidden(5, Globals.progress < Globals.Progression.Boundlessness)
	
	%Tabs/Dimensions.set_tab_hidden(1,
	PermaDims.DimsUnlocked == 0 and Globals.progress < GL.Progression.Boundlessness)
	%Tabs/Dimensions.set_tab_hidden(2, Globals.SDHandler.DimsUnlocked == 0)
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
	$ETint.visible = (Globals.progress >= GL.Progression.Permanence)
	
	$DTint.global_position = TBar.get_tab_rect(4).position + TBar.global_position\
	+ Vector2(-1, 1)
	$DTint.size            = TBar.get_tab_rect(4).size
	$DTint.color           = get_theme_color("meow", "DupliButton")
	$DTint.material.set_shader_parameter(
		"replace", get_theme_stylebox("panel", "TabContainer").bg_color
	)
	$DTint.visible = (Globals.progress >= GL.Progression.Duplicantes)
	
	$BTint.global_position = TBar.get_tab_rect(5).position + TBar.global_position\
	+ Vector2(-1, 1)
	$BTint.size            = TBar.get_tab_rect(5).size
	$BTint.color           = get_theme_color("font_color", "ButtonBLess")
	$BTint.material.set_shader_parameter(
		"replace", get_theme_stylebox("panel", "TabContainer").bg_color
	)
	$BTint.visible = (Globals.progress >= GL.Progression.Boundlessness)
	
	if Input.is_action_just_pressed("Debug"): debugMode = not debugMode
	TBar.set_tab_hidden(TBar.tab_count - 1, not debugMode)
	
	%Resources/Rewind/Button.disabled = \
	%Tabs/Dimensions/Tachyons.rewindNode.disabled
	%Resources/Rewind.visible = \
	%Tabs/Dimensions/Tachyons.rewindNode.visible
	
	%Resources/Permanence.visible = \
	Globals.progressBL >= GL.Progression.Overcome and \
	(Globals.Challenge == 0 or Globals.Challenge > 15)
	%Resources/Permanence/PermanenceButton.disabled = \
	not TachyonDims.canBigBang
	
	%Resources/PDunlock.visible = \
	Globals.progressBL >= GL.Progression.Overcome and \
	(Globals.Challenge == 0 or Globals.Challenge > 15) and \
	PermaDims.DimsUnlocked < 8 and \
	Globals.Boundlessnesses.to_float() < 25
	if PermaDims.DimsUnlocked < 8:
		%Resources/PDunlock/PDButton.disabled = (
			Currencies.Tachyons.AMOUNT.log10() < \
			PermaDims.TachLogReq[PermaDims.DimsUnlocked]
		)
	%Resources/PDunlock/PDButton.text = \
	"Reach %s TC\nto unlock a new\n%s Dimension." % [
		largenum.ten_to_the(PermaDims.TachLogReq[
			PermaDims.DimsUnlocked]
		).to_string(),
		"type of" if PermaDims.DimsUnlocked == 0 else "Permanence"
	]
	
	%Resources/Boundlessness.visible = \
	PermaDims.DimsUnlocked == 8 or \
	Globals.Boundlessnesses.to_float() >= 25
	if Currencies.PermanencePts.AMOUNT.exponent < 1024:
		%Resources/Boundlessness/BoundlessButton.disabled = true
		%Resources/Boundlessness/BoundlessButton.text = "Reach %s\nPermanence Points" % \
		largenum.two_to_the(1024)
	else:
		%Resources/Boundlessness/BoundlessButton.disabled = false
		%Resources/Boundlessness/BoundlessButton.text = "%s\n%s %s %s\n%s" % [
			"Other lands await…",
			"gain", Formulas.bpgained().to_string()\
			.trim_suffix(".00").trim_suffix(";00"), "BP",
			(
				"(%s%s %s)" % (
					[
						"next at ", Formulas.next_bp(), "PP"
					] if Formulas.bpgained().to_float() < 100 else [
						"", Formulas.bpgained().divide(Globals.boundTime),
						"BP/s"
					]
				)
			)
		]
	
	%Resources/PP.visible = (Globals.progress >= GL.Progression.Permanence)
	%Resources/Challenge.visible = (Globals.progress >= GL.Progression.Permanence)
	%Resources/Dupl.visible = (Globals.progress >= GL.Progression.Duplicantes)
	%Resources/BP.visible = (Globals.progress >= GL.Progression.Boundlessness)
	
	%Resources/Tachyons/Text.text = \
	"[center][font_size=16]%s[/font_size]\nTachyons[/center]" % Currencies.Tachyons.to_string()
	%Resources/PP/Text.text = \
	"[center][color=%s][font_size=16]%s[/font_size]\nPermanence Point%s[/color][/center]" % [
		get_theme_color("font_color", "ButtonEtern").to_html(false),
		Currencies.PermanencePts.AMOUNT.to_string().trim_suffix(".00").trim_suffix(";00"),
		"" if Currencies.PermanencePts.AMOUNT.exponent == 0 else "s"
	]
	%Resources/Dupl/Text.text = \
	"[center][color=%s][font_size=16]%s[/font_size]\nDuplican%ss[/color][/center]" % [
		get_theme_color("meow", "DupliButton").to_html(false),
		Globals.Duplicantes.to_string().trim_suffix(".00").trim_suffix(";00"),
		"" if Globals.Duplicantes.exponent == 0 else "te"
	]
	%Resources/BP/Text.text = \
	"[center][color=%s][font_size=16]%s[/font_size]\nBoundlessness Point%s[/color][/center]" % [
		get_theme_color("font_color", "ButtonBLess").to_html(false),
		Globals.BoundlessPts.to_string().trim_suffix(".00").trim_suffix(";00"),
		"" if Globals.BoundlessPts.exponent == 0 else "s"
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
	
	if %Resources/Permanence/PermanenceButton.disabled:
		%Resources/Permanence/PermanenceButton.text = "Reach\n%s Tachyons" % (
			largenum.two_to_the(1024) if Globals.Challenge <= 15 else
			Globals.ECTargets[Globals.Challenge - 16]
		).to_string()
	elif Globals.Challenge > 15:
		%Resources/Permanence/PermanenceButton.text = "Big Bang to\ncomplete the\nchallenge"
	else:
		%Resources/Permanence/PermanenceButton.text = "Big Bang for\n%s PP\n(%s PP/s)" % [
			Permanence.process_pp_gain().to_string().trim_suffix(".00").trim_suffix(";00"),
			Permanence.process_pp_gain().divide(Globals.eternTime).to_string()
		]

func rewind(score):
	%Tabs/Dimensions/Tachyons.rewind(score)

func theme_change(which):
	theme = which

func UNPAUSE():
	get_tree().paused = false
