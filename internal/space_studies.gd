extends Node

class SpaceStudy:
	var id := ""
	var reqs : Array = []
	var cost := 100
	var excludes : Array = []
	var multibranch := false
	var row := 0
	var size := Vector2(1,1)
	var effect : Callable
	var display := func(base, eff): return base;
	var basetext := ""
	
	static func setup(
		_id:String, _reqs, _cost, _row, _basetext:String,
		_eff=null, _display=null, _excludes=[], _size=Vector2(1,1)
		):
		var ST = SpaceStudy.new()
		ST.id=_id; ST.reqs=_reqs; ST.cost=_cost; ST.row=_row
		ST.basetext = _basetext
		if _eff != null: ST.effect = _eff
		ST.excludes=_excludes; ST.size=_size
		return ST
	
	func get_text():
		return display.call() + (
			"\n\nCost: %s Space Theorems" %
			Globals.int_to_string(cost)
		)

var tree : Array[SpaceStudy] = []

func _ready() -> void:
	tree.append(
		SpaceStudy.setup(
			"SD1", [], 0, 0,
			"Unlock the %s Space Dimension."
			, func(): return Currencies.Effect.new(1);
			, func(base, eff): return base % Globals.ordinal(eff);
		)
	)
	tree.append(
		SpaceStudy.setup(
			"1×1", [tree[0]], 4, 1,
			"Replace the Duplicantes limit with a softcap."
		)
	)
	tree.append(
		SpaceStudy.setup(
			"1×2", [tree[0]], 3, 1,
			"Improve the Duplicantes multiplier\n\n%s."
			, func(): return 
		)
	)
