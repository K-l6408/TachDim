@tool
extends Button
class_name FourButton

@export var pressed_two := false
@export var status :int:
	get:
		return int(pressed_two) * 2 + int(button_pressed)
	set(value):
		value = wrapi(value, 0, 3)
		pressed_two    = (value >> 1) > 0
		button_pressed = (value %  2) > 0

func _process(_delta):
	toggle_mode = true
	if pressed_two:
		add_theme_stylebox_override("normal",  get_theme_stylebox("thressed"))
		add_theme_stylebox_override("pressed", get_theme_stylebox("fouressed"))
		add_theme_stylebox_override("hover", get_theme_stylebox("threevered"))
	else:
		remove_theme_stylebox_override("normal")
		remove_theme_stylebox_override("pressed")
		remove_theme_stylebox_override("hover")

func _toggled(press):
	if not press: pressed_two = not pressed_two
