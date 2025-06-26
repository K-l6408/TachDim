@tool
extends ProgrammaticTheme

const DEFAULT_FONT = preload("res://fonts/fa-solid-900.ttf")
var VARIATIONS = {}

var STYLEBOX_COLORS : Dictionary[String, Color] = {
	"null": Color(0,0,0,0),
	"background": Color("222222"),
	"border": Color.GRAY,
	"font": Color.WHITE,
	"progressbar": Color("1b571b"),
	
	"tachyons": Color("63dd17"),
	"transp_tachyons": Color("63dd1780"),
	"dark_tachyons": Color("316e0b"),
	"permanence": Color("b241e3"),
	"dark_permanence": Color("582170"),
	"duplicantes": Color("4172e3"),
	"dark_duplicantes": Color("1e3a79"),
	"transcendence": Color("b67f33"),
	"dark_transcendence": Color("5b3f19"),
	
	"button": Color("575757"),    # 1
	"pressed": Color("37b037"),   # 2
	"disabled": Color("b03737"),  #
	"hover": Color("395739"),     # 1 → 2
	"special": Color.BLACK,       #
	"third": Color("b09113"),     # 3
	"fourth": Color("d662bb"),    # 4
	"hover_2nd": Color("6fa930"), # 2 → 3
	"hover_3rd": Color("b9843c"), # 3 → 4
	"hover_4th": Color("ac5a95"), # 4 → 1
	"special_off": Color("00000080"),
	"toggle_on": Color("b08737"),
	"toggle_off": Color("b0b037"),
	"toggle_hover": Color("b09c37"),
	
	"tab_disabled": Color("00000057"),
	"tab_hover": Color("00000020"),
	"tab_select": Color.BLACK,
}
var stylebox_colors = STYLEBOX_COLORS.duplicate()
var corner_rounding := 10
var border_size := 2

func global_setup():
	var fv := FontVariation.new(); var fb := FontVariation.new()
	fv.fallbacks = [fb]
	fv.base_font = DEFAULT_FONT
	fb.base_font = DEFAULT_FONT.fallbacks[0]
	fv.variation_transform = Transform2D(
		Vector2(1,0.5), Vector2(0,1), Vector2(0,0) )
	fb.variation_transform = Transform2D(
		Vector2(1,0.5), Vector2(0,1), Vector2(0,0) )
	VARIATIONS["Italic"] = fv
	
	fv = fv.duplicate(); fb = fb.duplicate(); fv.fallbacks = [fb]
	fv.variation_embolden = 1; fb.variation_embolden = 1
	VARIATIONS["Bold Italic"] = fv
	
	fv = fv.duplicate(); fb = fb.duplicate(); fv.fallbacks = [fb]
	fv.variation_transform = Transform2D.IDENTITY
	fb.variation_transform = Transform2D.IDENTITY
	VARIATIONS["Bold"] = fv
	
	stylebox_colors = STYLEBOX_COLORS.duplicate()

##_variant_to_parent_type_name = {
##		#"Study": "Button",
##		#"PDButton": "Button",
##		#"": "Button",
##		#"": "Button",
##		#"ButtonDupli": "Button",
##		#"ButtonTrans": "Button",
##		#"ToggleButton": "Button",
##		#"TransparentButton": "Button",
##		#
##		#"TooltipPanel": "Panel",
##		#"NotificationPanel": "Panel",
##	#}
func  setup_dark():
	global_setup()
	set_save_path("res://themes/Dark.tres")
	stylebox_colors.merge(
		{
			"tachyons": Color("64bc33"),
		}, true
	)
func setup_light():
	global_setup()
	set_save_path("res://themes/Light.tres")
	stylebox_colors.merge(
		{
			"background": Color.WHITE,
			"button": Color.WHITE,
			"border": Color.BLACK,
			"disabled": Color("ff4f4f"),
			"hover": Color("a8ffa8"),
			"pressed": Color("4fff4f"),
			"font": Color.BLACK,
			"tab_disabled": Color("00000057"),
			"tab_hover": Color("00000020"),
			"tab_select": Color.WHITE,
			"special": Color.WHITE,
			"special_off": Color("00000020"),
			"dark_tachyons": Color("b0ed8a"),
			"dark_permanence": Color("d89ff0"),
			"dark_duplicantes": Color("1e3a79"),
		}, true
	)
func setup_glass():
	global_setup()
	set_save_path("res://themes/Glass.tres")
	stylebox_colors.merge(
		{
			"background": Color("22222222"),
		}, true
	)

# CTRL + SHIFT + X to run!
func define_theme():
	define_default_font(DEFAULT_FONT)
	define_default_font_size(12)
	
	define_style("Label", {
		"font_color": stylebox_colors.font
	})
	define_style("RichTextLabel", {
		"default_color": stylebox_colors.font,
		"bold_font": VARIATIONS["Bold"],
		"italics_font": VARIATIONS["Italic"],
		"bold_italics_font": VARIATIONS["Bold Italic"],
	})
	
	define_style("Panel", {
		"panel": make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.border
		}, border_size, 0)
	})
	define_variant_style("TachPanel", "Panel", {
		"panel": make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.tachyons
		}, border_size, 0)
	})
	define_variant_style("PermPanel", "Panel", {
		"panel": make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.permanence
		}, border_size, 0)
	})
	define_variant_style("TooltipPanel", "Panel", {
		"panel": inherit(make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding), content_margins(5))
	})
	
	define_style("PanelContainer", {
		"panel": inherit(make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.border
		}, border_size, 0), content_margins(5))
	})
	
	define_style("LineEdit", {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"read_only": make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.button
		}, border_size, corner_rounding),
		"font_color": stylebox_colors.font,
	})
	
	define_style("TabContainer", {
		"panel": inherit(make_flat_stylebox( {
			"bg_color": stylebox_colors.background,
			"border_color": stylebox_colors.border,
			"expand_margin_left": border_size,
		}, border_size, 0), content_margins(5)),
		"tab_disabled": make_flat_stylebox( {
			"bg_color": stylebox_colors.tab_disabled,
			"border_color": stylebox_colors.border,
			"expand_margin_left": border_size,
			"expand_margin_bottom": border_size,
			"content_margin_left": 4,
			"content_margin_top": 4,
			"content_margin_right": 4 + border_size,
		}, border_size, 0),
		"tab_hovered": make_flat_stylebox( {
			"bg_color": stylebox_colors.tab_hover,
			"border_color": stylebox_colors.border,
			"expand_margin_left": border_size,
			"expand_margin_bottom": border_size,
			"content_margin_left": 4,
			"content_margin_top": 4,
			"content_margin_right": 4 + border_size,
		}, border_size, 0),
		"tab_selected": make_flat_stylebox( {
			"bg_color": stylebox_colors.tab_select,
			"border_color": stylebox_colors.border,
			"expand_margin_left": border_size,
			"expand_margin_bottom": border_size,
			"content_margin_left": 4,
			"content_margin_top": 4,
			"content_margin_right": 4 + border_size,
		}, border_size, 0),
		"tab_unselected": make_flat_stylebox( {
			"bg_color": stylebox_colors["null"],
			"border_color": stylebox_colors.border,
			"expand_margin_left": border_size,
			"expand_margin_bottom": border_size,
			"content_margin_left": 4,
			"content_margin_top": 4,
			"content_margin_right": 4 + border_size,
		}, border_size, 0),
		"tabbar_background": make_flat_stylebox( {
			"bg_color": stylebox_colors["null"],
			"expand_margin_left": border_size,
			"expand_margin_bottom": border_size,
			"content_margin_left": 4,
			"content_margin_top": 4,
			"content_margin_right": 4 + border_size,
		}, 0, 0),
		"tab_focus": stylebox_empty({}),
		"side_margin": 0,
		"font_hovered_color": stylebox_colors.font,
		"font_unselected_color": stylebox_colors.font,
		"font_selected_color": stylebox_colors.font,
	})
	
	define_style("MarginContainer", {"margin_left":2,"margin_top":2})
	
	define_style("ProgressBar", {
		"background": make_flat_stylebox( {
			"bg_color": stylebox_colors.button,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"fill": make_flat_stylebox( {
			"bg_color": stylebox_colors.progressbar,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"font_color": stylebox_colors.font,
	})
	define_variant_style("TachProgressBar", "ProgressBar", {
		"background": make_flat_stylebox( {
			"bg_color": stylebox_colors.button,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"fill": make_flat_stylebox( {
			"bg_color": stylebox_colors.dark_tachyons,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
	})
	
	define_style("Button", {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors.button,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.pressed,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover_pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"disabled": make_flat_stylebox( {
			"bg_color": stylebox_colors.disabled,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"focus": stylebox_empty({}),
		"font_color": stylebox_colors.font,
		"font_hover_color": stylebox_colors.font,
		"font_focus_color": stylebox_colors.font,
		"font_pressed_color": stylebox_colors.font,
		"font_disabled_color": stylebox_colors.font,
	})
	define_style("CheckButton", {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors.button,
			"border_color": stylebox_colors.border,
			"content_margin_left": 7
		}, border_size, corner_rounding),
		"pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.pressed,
			"border_color": stylebox_colors.border,
			"content_margin_left": 7
		}, border_size, corner_rounding),
		"hover": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover,
			"border_color": stylebox_colors.border,
			"content_margin_left": 7
		}, border_size, corner_rounding),
		"hover_pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover,
			"border_color": stylebox_colors.border,
			"content_margin_left": 7
		}, border_size, corner_rounding),
		"disabled": make_flat_stylebox( {
			"bg_color": stylebox_colors.disabled,
			"border_color": stylebox_colors.border,
			"content_margin_left": 7
		}, border_size, corner_rounding),
		"focus": stylebox_empty({}),
		"font_color": stylebox_colors.font,
		"font_hover_color": stylebox_colors.font,
		"font_focus_color": stylebox_colors.font,
		"font_pressed_color": stylebox_colors.font,
		"font_disabled_color": stylebox_colors.font,
	})
	define_variant_style("FourButton", "Button", {
		"thressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.third,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"fouressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.fourth,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover_pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover_2nd,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"threevered": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover_3rd,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"fouvered": make_flat_stylebox( {
			"bg_color": stylebox_colors.hover_4th,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
	})
	define_variant_style("ToggleButton", "Button", {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors.toggle_off,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.toggle_on,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover": make_flat_stylebox( {
			"bg_color": stylebox_colors.toggle_hover,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover_pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.toggle_hover,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
	})
	define_variant_style("TranspTach", "Button", {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors["null"],
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.tachyons,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover": make_flat_stylebox( {
			"bg_color": stylebox_colors.transp_tachyons,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover_pressed": make_flat_stylebox( {
			"bg_color": stylebox_colors.tachyons,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"disabled": make_flat_stylebox( {
			"bg_color": stylebox_colors.disabled,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
	})
	define_variant_style("ButtonTach", "Button",
		special_button(
			stylebox_colors.tachyons,
			stylebox_colors.dark_tachyons))
	define_variant_style("ButtonPerm", "Button",
		special_button(
			stylebox_colors.permanence,
			stylebox_colors.dark_permanence))
	define_variant_style("ButtonDupli", "Button",
		special_button(
			stylebox_colors.duplicantes,
			stylebox_colors.dark_duplicantes))
	define_variant_style("ButtonTrans", "Button",
		special_button(
			stylebox_colors.transcendence,
			stylebox_colors.dark_transcendence))

func special_button(color, dark):
	return {
		"normal": make_flat_stylebox( {
			"bg_color": stylebox_colors.special,
			"border_color": color
		}, border_size, corner_rounding),
		"pressed": make_flat_stylebox( {
			"bg_color": color,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"hover": make_flat_stylebox( {
			"bg_color": dark,
			"border_color": stylebox_colors.border
		}, border_size, corner_rounding),
		"disabled": make_flat_stylebox( {
			"bg_color": stylebox_colors.special_off,
			"border_color": dark
		}, border_size, corner_rounding),
		"enabled": make_flat_stylebox( {
			"bg_color": color,
			"border_color": stylebox_colors.border,
			"border_blend": true
		}, 7, corner_rounding),
		"font_color": color,
		"font_pressed_color": stylebox_colors.font,
		"disabled_color": stylebox_colors.button,
	}

func make_flat_stylebox(colors, bsize, cround):
	return stylebox_flat(
		merge(
			colors,
			border_width(bsize),
			corner_radius(cround),
			{"anti_aliasing": false}
		)
	)
