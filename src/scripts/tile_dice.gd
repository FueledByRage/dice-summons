extends TileMapLayer

@onready var TABLE = get_tree().get_first_node_in_group('table');

var used_cells = get_used_cells();
var CENTER_CELL = Vector2(1,2);

func _process(delta: float) -> void:
	pass

func get_used_cells_map():
	var cells_map = [];
	for cell in used_cells:
		cells_map.push_back(map_to_local(cell));
	return cells_map;
