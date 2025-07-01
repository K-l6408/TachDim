extends Node

class SpaceStudy:
	var id := ""
	var reqs : Array[SpaceStudy] = []
	var cost := 100
	var excludes : Array[SpaceStudy] = []
	var multibranch := false
	var row := 0
	var size := Vector2(1,1)
	var effect : Callable
	var basetext := ""
	
	static func setup(
		_id:String, _reqs, _cost, _row, _basetext:String,
		_eff=null, _excludes=[], _size=Vector2(1,1)
		):
		var ST = SpaceStudy.new()
		ST.id=_id; ST.reqs=_reqs; ST.cost=_cost; ST.row=_row
		ST.basetext = _basetext
		if _eff != null: ST.effect = _eff
		ST.excludes=_excludes; ST.size=_size
		return ST
	
	

var tree : Array[SpaceStudy] = []

func _ready() -> void:
	tree.append(
		SpaceStudy.setup(
			"SD1", [], 0, 0,
			"",
			func(): return 1;
		)
	)
