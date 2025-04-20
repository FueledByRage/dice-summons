extends Node2D

@onready var table = get_parent();

var FORMS = [
	[
		Vector2(0,0),
		Vector2(0, -1),
		Vector2(0, -2),
		Vector2(-1,0),
		Vector2(1,0),
		Vector2(0, 1)
	],
]

func _process(delta: float) -> void:
	global_position = table.get_selected_tile();
	pass
