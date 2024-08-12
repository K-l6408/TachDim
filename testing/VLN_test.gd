extends Node2D

func _process(_delta):
	Globals.display = GL.DisplayMode.Factorial
	
	var JJ = largenum.new(1)
	JJ.exponent = 10 ** $SpinBox.value
	var KK = largenum.new($SpinBox2.value)
	$Label.text = JJ.to_string() + "\n" + KK.to_string()

func bin_string(m):
	var n = m
	var ret_str = ""
	while n > 0:
		ret_str = str(n&1) + ret_str
		n >>= 1
	return ret_str
