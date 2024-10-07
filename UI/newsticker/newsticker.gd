extends PanelContainer

@export var waitbtwlines = 3.0
const news = preload("res://UI/newsticker/news.dialogue")
@onready var label : DialogueLabel = $DialogueLabel
var waitingtime = 0.0

func _process(delta):
	if not label.is_typing:
		waitingtime -= delta
		if waitingtime <= 0:
			if label.dialogue_line == null:
				label.dialogue_line = await news.get_next_dialogue_line(get_title())
				waitingtime = waitbtwlines
			elif await news.get_next_dialogue_line(label.dialogue_line.next_id) != null:
				label.dialogue_line = await news.get_next_dialogue_line(label.dialogue_line.next_id)
			else:
				label.dialogue_line = await news.get_next_dialogue_line(get_title())
				waitingtime = waitbtwlines
			label.type_out()

func get_title():
	return "g%d" % randi_range(1, 30)
