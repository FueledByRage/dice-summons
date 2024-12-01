extends TileMapLayer

var dice_path = {
	Vector2(1,2): Vector2i(1,1),
};

var used_cells = get_used_cells();

func _ready() -> void:
	y_sort_origin = 2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init_tile(dice_map):
	for face_coords in dice_map:
		var face = Vector2i(1,1);
		dice_path[face_coords] = face;
		set_cell(face_coords, 0, face, 0);

func get_global_path():
	var cells_paths = [];
	for cell in used_cells:
		cells_paths.push_back(map_to_local(cell));
	return cells_paths;
