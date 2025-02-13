extends Node2D

@onready var table = get_parent();

func _process(delta: float) -> void:
	global_position = table.get_selected_tile();
	pass
