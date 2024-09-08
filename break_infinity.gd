extends Resource
class_name largenum

var mantissa : int = 0
var exponent : float = 0
var sign := 1

func _init(from):
	if from is largenum:
		mantissa = from.mantissa
		exponent = from.exponent
		return
	
	sign = sign(from)
	from = abs(from)
	if from == 0:
		mantissa = 0
		exponent = -INF
		return
	exponent = floor(log(from) / GL.LOG2)
	mantissa = from * 2 ** (62 - exponent)
	exponent -= 1
	fix_mantissa()

static func two_to_the(xponent := 1.0) -> largenum:
	var l = largenum.new(2 ** (xponent - floor(xponent)))
	l.exponent = floor(xponent)
	return l

static func five_to_the(xponent := 1.0) -> largenum:
	return two_to_the(xponent * (GL.LOG10 - GL.LOG2) / GL.LOG2)

static func ten_to_the(xponent := 1.0) -> largenum:
	return two_to_the(xponent * GL.LOG10 / GL.LOG2)

static func dozen_to_the(xponent := 1.0) -> largenum:
	return two_to_the(xponent * GL.LOG12 / GL.LOG2)

func neg() -> largenum:
	var result = largenum.new(self)
	result.sign *= -1
	return result

func fix_mantissa():
	if exponent != floor(exponent):
		mantissa *= 2 ** (exponent - floor(exponent))
		exponent = floor(exponent)
	if mantissa == 0:
		exponent = 1.0 / -0.0
	if mantissa >= 1 << 62:
		mantissa >>= 1
		exponent += 1
	if mantissa < 1 << 61:
		mantissa <<= 1
		exponent -= 1
	if sign == 0: sign = 1

func add(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	var result = largenum.new(0)
	if abs(exponent - b.exponent) > 62:
		return largenum.new(self) if (exponent > b.exponent) else b
	var maxexp = max(exponent, b.exponent)
	result.exponent = maxexp
	result.mantissa = (sign * mantissa >> int(maxexp - exponent)) + (b.sign * b.mantissa >> int(maxexp - b.exponent))
	result.sign = sign(result.mantissa)
	result.mantissa = abs(result.mantissa)
	result.fix_mantissa()
	return result

func add2self(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	if abs(exponent - b.exponent) > 62:
		if (b.exponent > exponent):
			mantissa = b.mantissa
			exponent = b.exponent
		return self
	var maxexp = max(exponent, b.exponent)
	mantissa = (sign * mantissa >> int(maxexp - exponent)) + (b.sign * b.mantissa >> int(maxexp - b.exponent))
	sign = sign(mantissa)
	mantissa = abs(mantissa)
	exponent = maxexp
	fix_mantissa()
	return self

func multiply(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	var result = largenum.new(0)
	var m1 = float(mantissa)
	var m2 = float(b.mantissa)
	var mm = m1 * m2 / (2**61)
	result.mantissa = mm
	result.exponent = exponent + b.exponent
	result.sign = sign * b.sign
	result.fix_mantissa()
	if b.exponent < 0:
		pass
	return result

func divide(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	var result = largenum.new(0)
	var m1 = mantissa
	var m2 = b.mantissa >> 31
	if m2 == 0:
		return largenum.new(0)
	result.mantissa = (m1 / m2) << 30
	result.exponent = exponent - b.exponent
	result.sign = sign * b.sign
	result.fix_mantissa()
	return result

func mult2self(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	var m1 = mantissa >> 31
	var m2 = b.mantissa >> 31
	mantissa = m1 * m2 * 2
	exponent = exponent + b.exponent
	fix_mantissa()
	return self

func div2self(b) -> largenum:
	if not b is largenum:
		b = largenum.new(b)
	var result = largenum.new(0)
	var m1 = mantissa
	var m2 = b.mantissa >> 31
	if m2 == 0:
		return largenum.new(0)
	mantissa = (m1 / m2) << 30
	exponent = exponent - b.exponent
	fix_mantissa()
	return result

func power(b:float) -> largenum:
	if b == 0: return largenum.new(1)
	var result = largenum.new(0)
	result.exponent = exponent * float(b)
	var M = (log(mantissa) / GL.LOG2 - 61) * float(b)
	result.exponent += floor(M)
	result.mantissa = 2 ** ((M - floor(M)) + 61)
	result.fix_mantissa()
	return result

func pow2self(b:float) -> largenum:
	if b == 0: return largenum.new(1)
	exponent = exponent * float(b)
	var M = (log(mantissa) / GL.LOG2 - 61) * float(b)
	exponent += floor(M)
	mantissa = 2 ** ((M - floor(M)) + 61)
	fix_mantissa()
	return self

func to_float() -> float:
	if exponent == -INF:
		return 0
	elif exponent >= 1024:
		return sign * INF
	else:
		return sign * float(mantissa) * 2**(exponent - 61)

func log2() -> float:
	var m = float(mantissa) / (2 ** 61)
	return exponent + (log(m) / GL.LOG2)

func log10() -> float:
	return log2() * GL.LOG2 / GL.LOG10

func less(b) -> bool:
	fix_mantissa()
	if not b is largenum:
		b = largenum.new(b)
	b.fix_mantissa()
	if sign < b.sign:
		return true
	if floor(exponent) < floor(b.exponent):
		return true
	if floor(exponent) == floor(b.exponent) and mantissa <= b.mantissa:
		return true
	return false

func _to_string() -> String:
	var logfinity = 1024
	if Globals.Challenge == 15: logfinity = 2048
	if log2() >= logfinity and (
		Globals.progressBL < GL.Progression.Overcome or (
			Globals.Challenge != 0 and Globals.Challenge <= 15
		)
	):
		return "Infinite"
	
	match Globals.display:
		GL.DisplayMode.Scientific:
			var l = log10()
			if l == -INF:
				return "0.00"
			var m = 10 ** (l - floor(l))
			if abs(to_float()) < 1e3 and abs(to_float()) > 0.009:
				return "%.2f" % to_float()
			if m > 9.999:
				l = ceil(l)
				m = 1
			if l > 1e5:
				return "e%.2fe%.0f" % [l/10**floor(log(l)/GL.LOG10), (log(l)/GL.LOG10)]
			return "%.2fe%.0f" % [m*sign, floor(l)]
		GL.DisplayMode.Engineering:
			var l = log10() / 3
			if l == -INF:
				return "0.00"
			var m = 1000 ** (l - floor(l))
			if abs(to_float()) < 1e3 and abs(to_float()) > 0.009:
				return "%.2f" % to_float()
			if m > 999.99:
				l = ceil(l)
				m = 1
			if l > 1e5:
				return "e%.2fe%.0f" % [
					l/10**floor(log(l)/GL.LOG10),
					log(l)/GL.LOG10
				]
			return "%.2fe%.0f" % [m*sign, floor(l) * 3]
		GL.DisplayMode.Standard:
			var l = log10() / 3
			var m = 1000 ** (l - floor(l))
			if abs(to_float()) < 1e3:
				return "%.2f" % to_float()
			if m > 999.99:
				l = ceil(l)
				m = 1
			return "%.2f %s" % [m*sign, largenum.standard(l-1)]
		GL.DisplayMode.Logarithm:
			var l = log10()
			if l == -INF:
				return "0.00"
			if abs(to_float()) < 1e3 and abs(to_float()) > 0.009:
				return "%.2f" % to_float()
			if l > 1e5:
				return "ee%.2f" % (log(l)/GL.LOG10)
			return "e%.2f" % l
		GL.DisplayMode.Letters:
			var l = log10()
			if l == -INF:
				return "0.00"
			var m = 10 ** (l - floor(l))
			if abs(to_float()) < 999.999 and abs(to_float()) > 0.009:
				return "%.2f" % to_float()
			var s = ""
			var alpha = "abcdefghijklmnopqrstuvwxyz"
			if m > 9.99:
				l = ceil(l)
				m = 1
			var k = ceil(fmod(l, 3) - 0.9999999)
			l = floor(l / 3)
			while l >= 1:
				s = alpha[(fmod(l, 26) as int) - 1] + s
				l /= 27
			return "%.2f%s" % [m * 10**k, s]
		GL.DisplayMode.Dozenal:
			var l = log2() * GL.LOG2 / GL.LOG12 
			if l == -INF:
				return "0;00"
			var m = 12 ** (l - floor(l))
			if l < 3:
				return largenum.dozenal(to_float())
			if l > 12 ** 5:
				return "e%se%s" % [
					largenum.dozenal(l / 12 ** floor(log(l) / GL.LOG12)),
					largenum.dozenal(log(l) / GL.LOG12, 0)
				]
			return "%se%s" % [largenum.dozenal(m), largenum.dozenal(l,0)]
		GL.DisplayMode.Strict_Logarithm:
			if log10() < 1e3:
				return ("e%.2f" % log10()).replace("inf", "∞")
			return "ee%.2f" % (log(log10()) / GL.LOG10)
		GL.DisplayMode.Roman:
			var l = log10() / 3
			if l < 3.3333:
				var m = to_float()
				if abs(m - round(m)) < 0.05: m = round(m)
				return largenum.roman(m)
			var S = ""
			if l >= 1e18:
				S = largenum.roman(floor(log(l) / GL.LOG10)) + "/" + largenum.roman(fmod(l, 1000))
			elif l <= 5:
				for i in floor(l):
					S += "/"
			else:
				S = largenum.roman(floor(l)) + "/"
			var m = 1000 ** (l - floor(l))
			if abs(m - round(m)) < 0.01: m = round(m)
			return S + largenum.roman(m)
		GL.DisplayMode.sitelen_pona:
			var l = log10() / 2
			var m = 100 ** fmod(l, 1)
			if m > 99.999:
				l = ceil(l)
				m = 1
			if l >= 1e4:
				return "󱤄󱥵" + largenum.sitelen(l, true)
			elif l >= 5:
				return (largenum.sitelen(m, true) if round(m) > 1 else "") + "󱤄󱥵" + largenum.sitelen(l, true)
			return largenum.sitelen(to_float())
		GL.DisplayMode.toki_pona:
			Globals.display = GL.DisplayMode.sitelen_pona
			var s = _to_string()
			Globals.display = GL.DisplayMode.toki_pona
			return s\
			.replace("󱥳", " wan").replace("󱥮", " tu")\
			.replace("󱤭", " luka").replace("󱤼", " mute")\
			.replace("󱤄", " ale").replace("󱥵", " wawa")\
			.replace("󱥻", " kipisi").replace("󱤊", " en")\
			.replace("󱤂", " ala").replace("󱦂", " meso").trim_prefix(" ")
		GL.DisplayMode.Canonical_toki_pona:
			if to_float() < 1: return "ala"
			if to_float() < 2: return "wan"
			if to_float() < 3: return "tu"
			return "mute"
		GL.DisplayMode.Evil:
			if exponent == -INF:
				return "0.00"
			var l = log10() * (1 + sin(log10()) / 10)
			var m = 10 ** (l - floor(l))
			if abs(to_float()) < 1e3 and abs(to_float()) > 0.009:
				return Globals.float_to_string(to_float())
			if m > 9.999:
				l = ceil(l)
				m = 1
			if l > 1e5:
				return "e%.2fe%.0f" % [l/10**floor(log(l)/GL.LOG10), (log(l)/GL.LOG10)]
			return "%.2fe%.0f" % [m, floor(l)]
		GL.DisplayMode.Factorial:
			if abs(to_float()) < 1000:
				return "%.2f" % to_float()
			return "%.3f!" % (sign * invfact())
	return "N/A"

static func standard(e) -> String:
	if e < 1: return "K"
	if e < 2: return "M"
	if e < 3: return "B"
	var s = ""
	while e > 1:
		s += ["", "U",  "D",  "T",  "Qa", "Qt", "Sx", "Sp", "O",  "N" ][fmod(e, 10  )      ]
		s += ["", "Dc", "Vg", "Tg", "Qd", "Qi", "Se", "St", "Og", "Nn"][fmod(e, 100 ) / 10 ]
		s += ["", "Ce", "Dn", "Tc", "Qe", "Qu", "Sc", "Si", "Oe", "Ne"][fmod(e, 1000) / 100]
		e /= 1000
		s += "MI-"
	return s.trim_suffix("MI-")

static func dozenal(f:float, precision:=2) -> String:
	var S = \
	String.num_int64(f * 12**precision, 12).\
	replace("a", "↊").\
	replace("b", "↋")
	if precision > 0: S = S.insert(S.length()-precision, ";")
	if S[0] == ";": S = "0" + S
	return S

static func roman(f:float) -> String:
	if f < 1./12.: return "N"
	var s := ""
	if f >= 10000:
		var k = roman(int(f/1000))
		for i in k:
			s += i
			if i != "̅":
				s += "̅"
		f = fmod(f, 1000)
	while f >= 1000:
		f -= 1000
		s += "M"
	match int(f / 100):
		9: s += "CM"
		8: s += "DCCC"
		7: s += "DCC"
		6: s += "DC"
		5: s += "D"
		4: s += "CD"
		3: s += "CCC"
		2: s += "CC"
		1: s += "C"
	f = fmod(f, 100)
	match int(f / 10):
		9: s += "XC"
		8: s += "LXXX"
		7: s += "LXX"
		6: s += "LX"
		5: s += "L"
		4: s += "XL"
		3: s += "XXX"
		2: s += "XX"
		1: s += "X"
	f = fmod(f, 10)
	match int(f):
		9: s += "IX"
		8: s += "VIII"
		7: s += "VII"
		6: s += "VI"
		5: s += "V"
		4: s += "IV"
		3: s += "III"
		2: s += "II"
		1: s += "I"
	if fmod(f, 1) >= 0.5: s += "S"
	f = fmod(f, 0.5) * 12
	match int(f):
		1: s += "·"
		2: s += ":"
		3: s += "∴"
		4: s += "∷"
		5: s += "⁙"
	return s

static func sitelen(f:float, forceint := false) -> String:
	var s = ""
	if forceint: f = round(f)
	if   f >= 200: s += sitelen(floor(f / 100)) + "󱤄"
	elif f >= 100: s += "󱤄"
	f = fmod(f, 100)
	if   f >= 40: s += sitelen(floor(f / 20)) + "󱤼"
	elif f >= 20: s += "󱤼"
	f = fmod(f, 20)
	if   f >= 10: s += sitelen(floor(f / 5)) + "󱤭‍"
	elif f >=  5: s += "󱤭‍"
	f = fmod(f, 5)
	match int(f):
		1: s += "󱥳"
		2: s += "󱥮‍"
		3: s += "󱥮‍󱥳"
		4: s += "󱥮‍󱥮"
	f = fmod(f, 1)
	if f < 0.01 or forceint:
		if s == "": return "󱤂"
		else: return s
	if abs(round(2*f) - 2*f) <= 0.01:
		return s + "󱦂"
	if s != "": s += "󱤊"
	var a = 100
	for b in [3,4,5,6,7,8,9,10,15,20,25,30,35,40,100]:
		if abs(round(b*f) - b*f) <= 0.01:
			a = b
			break
	return s + sitelen(a * f, true) + "󱥻" + sitelen(a, true)

func invfact() -> float: # approximation of ðe gamma function's inverse
	var L = divide(sqrt(TAU)).log2() * GL.LOG2
	return L / Globals.lambertw(L / exp(1)) - 0.5

func from_bytes(data : PackedByteArray):
	mantissa = data.decode_u64(0)
	exponent = data.decode_double(8)
	return self

func to_bytes() -> PackedByteArray:
	var result : PackedByteArray
	result.resize(16)
	result.encode_u64   (0, mantissa)
	result.encode_double(8, exponent)
	return result
