extends TileMapLayer

var WIDTH = 12
var HEIGHT = 20

var maped_table: Dictionary = {}

@onready var units = get_parent().get_node("Units");

var placing_dice
var path = []
var summons_map = []
var select_targets = []
var possible_move_cells = []
var selected_target_index = 0

func _ready() -> void:
	add_to_group("table")
	set_table()

func _process(delta: float) -> void:
	pass

func set_table() -> void:
	for column in range(WIDTH):
		for row in range(HEIGHT):
			if is_within_bounds(Vector2i(column, row)):
				set_cell(Vector2(column, row), 0, Vector2i(0, 1), 0)

func is_within_bounds(tile: Vector2) -> bool:
	return tile.x >= 0 and tile.x < WIDTH and tile.y >= 0 and tile.y < HEIGHT

func get_selected_tile():
	var tile = local_to_map(get_global_mouse_position())
	return map_to_local(tile)

func place():
	var selected_tile = get_selected_tile();
	var dice_scene = preload("res://src/scenes/dice.tscn")
	var dice_instance = dice_scene.instantiate()
	
	placing_dice.queue_free()
	build_dice(selected_tile)
	summon(selected_tile)

func build_dice(dice_center: Vector2):
	var dice_face = Vector2i(1,1)
	var form = [
		Vector2(0,0),
		Vector2(0, -1),
		Vector2(0, -2),
		Vector2(-1,0),
		Vector2(1,0),
		Vector2(0, 1)
	]
	
	for cell_form in form:
		var cell_coord = local_to_map(to_local(dice_center) + (cell_form * 32))
		path.push_back(cell_coord)
		set_cell(cell_coord, 0, dice_face, 0)

func summon(position):
	var summon_scene = preload("res://src/scenes/summon.tscn")
	var summon_instance = summon_scene.instantiate()
	
	summon_instance.global_position = to_local(get_selected_tile())
	add_child(summon_instance)
	add_summon_to_path(summon_instance)

func add_summon_to_path(summon):
	units.allies_units.append({
		"node": summon,
		"name": summon.name,
		"label": summon.name, 
		"local": to_local(summon.global_position),
		"global_local": summon.global_position
	})

func highlight_summon_possible_moves(summon_position):
	var possible_moves = calculate_possible_moves(summon_position, 5);
	for move in possible_moves:
		set_cell(move, 0, Vector2i(0,0));

func calculate_possible_moves(position, tile_moves):
	var directions = {
		"up": Vector2(0, -32),
		"up_right": Vector2(32,-32),
		"up_left": Vector2(-32, -32),
		"down": Vector2(0, 32),
		"down_right": Vector2(32,32),
		"down_left": Vector2(-32,32),
		"left": Vector2(-32, 0),
		"right": Vector2(32, 0)
	}
	
	var possible_moves = [];
	
	for direction in directions.keys():
		var moves = calculate_moves_in_direction(position, tile_moves, directions[direction])
		possible_moves.append_array(moves);
	
	return possible_moves;

func highlight_possible_moves(possible_move_cells):
	for cell in possible_move_cells:
		set_cell(cell, 0, Vector2(0,0), 0)

func move_summon(summon, new_position):
	summon.position = map_to_local(new_position)


func to_placing():
	var placing_dice_scene = preload("res://src/scenes/place_dice.tscn");
	var placing_dice_instance = placing_dice_scene.instantiate();
	
	add_child(placing_dice_instance);
	
	placing_dice = placing_dice_instance;


func calculate_moves_in_direction(current_tile: Vector2, moves : int, direction: Vector2):
	var path = [];
	var next_tile = current_tile + direction;
	
	while is_tile_a_path(next_tile) && moves > 0:
		path.append(local_to_map(next_tile));
		moves -= 1
		next_tile += direction;
	
	return path;

func is_tile_a_path(tile_coord):
	var cell_atlas_coords = get_cell_atlas_coords(local_to_map(tile_coord))
	return is_within_bounds(cell_atlas_coords) && cell_atlas_coords == Vector2i(1,1)
