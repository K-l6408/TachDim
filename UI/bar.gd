extends Window

var screen : Rect2i :
	get:
		return DisplayServer.screen_get_usable_rect(current_screen)

var side = CORNER_BOTTOM_LEFT

func _ready():
	$HBoxContainer/Prestiges/Dilation/Button.connect(
		"pressed", TachyonDims.dilate
	)
	$HBoxContainer/Prestiges/TGalaxy/Button.connect(
		"pressed", TachyonDims.galaxy
	)
	
	$"HBoxContainer/Move/To/1".connect("pressed", func():
		side = CORNER_TOP_LEFT
	)
	$"HBoxContainer/Move/To/2".connect("pressed", func():
		side = CORNER_TOP_RIGHT
	)
	$"HBoxContainer/Move/To/3".connect("pressed", func():
		side = CORNER_BOTTOM_LEFT
	)
	$"HBoxContainer/Move/To/4".connect("pressed", func():
		side = CORNER_BOTTOM_RIGHT
	)

#func _unhandled_input(e:InputEvent):
	#get_tree().root.push_input(e)
	#if has_focus():
		#get_tree().root.grab_focus()

func _process(delta):
	size = Vector2(screen.size.x / 2, 70)
	mode = MODE_WINDOWED
	var target_position := position
	match side:
		CORNER_BOTTOM_LEFT:
			target_position = Vector2(
				screen.position.x,
				screen.position.y + screen.size.y - size.y
			)
		CORNER_BOTTOM_RIGHT:
			target_position = Vector2(
				screen.position.x + screen.size.x - size.x,
				screen.position.y + screen.size.y - size.y
			)
		CORNER_TOP_LEFT:
			target_position = Vector2(
				screen.position.x,
				screen.position.y
			)
		CORNER_TOP_RIGHT:
			target_position = Vector2(
				screen.position.x + screen.size.x - size.x,
				screen.position.y
			)
	
	var velocity = Vector2(target_position - position).normalized() * 4000
	position = Vector2(
		move_toward(position.x, target_position.x, abs(delta * velocity.x)),
		move_toward(position.y, target_position.y, abs(delta * velocity.y))
	)
	
	mouse_passthrough_polygon = [
		Vector2(0,0),Vector2(0,size.y),size,Vector2(size.x,0)
	] as PackedVector2Array
	
	$HBoxContainer/Prestiges/Dilation/Button.disabled = \
	not TachyonDims.canDilate
	$HBoxContainer/Prestiges/TGalaxy/Button.disabled = \
	not TachyonDims.canGalaxy
	$HBoxContainer/Rewind.visible = (
		(TachyonDims.TDilation >= 5) or \
		(Globals.progress >= Globals.Progression.Galaxy)
	) and not Globals.Achievemer.is_unlocked(5,2)
	
	if get_theme_stylebox("panel", "Panel") is StyleBoxFlat:
		$HBoxContainer/Prestiges/Dilation/Button.add_theme_color_override(
			"font_outline_color",
			get_theme_stylebox("panel", "Panel").bg_color
		)
		$HBoxContainer/Prestiges/TGalaxy/Button.add_theme_color_override(
			"font_outline_color",
			get_theme_stylebox("panel", "Panel").bg_color
		)
	
	$HBoxContainer/Tachyons/Text.text = \
	"[center][font_size=16]%s[/font_size]\nTachyons[/center]" % Currencies.Tachyons.to_string()
	$HBoxContainer/Prestiges/Dilation/Button.text = "%s/%s\n%s Dimensions" % [
		Globals.int_to_string(TachyonDims.DimPurchase[TachyonDims.DimsUnlocked - 1]),
		Globals.int_to_string(TachyonDims.dilacost()),
		Globals.ordinal(TachyonDims.DimsUnlocked)
	]
	$HBoxContainer/Prestiges/TGalaxy/Button.text = "%s/%s\n%s Dimensions" % [
		Globals.int_to_string(TachyonDims.DimPurchase[5 if Globals.Challenge in [6, 16] else 7]),
		Globals.int_to_string(TachyonDims.galacost()),
		Globals.ordinal(6 if Globals.Challenge in [6, 16] else 8)
	]
