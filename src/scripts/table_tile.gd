extends TileMapLayer

class_name Board

var WIDTH = 12
var HEIGHT = 20

signal dice_placed;

@onready var units = $Units;
@onready var stage = get_parent();

var dice_limit = 5;

var maped_table: Dictionary = {}
var path = []
var summons_map = []
var select_targets = []
var possible_move_cells = []
var selected_target_index = 0
var summon_on_move

var select_dice_cells = [];
var is_placing = false;
var prev_selected_tile

var selected_form_index = 0;
var prev_selected_form_index = 0;

var FORMS = [
	{
		"height": 3,
		"form": [
			Vector2(0,0),
			Vector2(0, -1),
			Vector2(0, -2),
			Vector2(-1,0),
			Vector2(1,0),
			Vector2(0, 1)
		]
	},
	{
		"height": 3,
		"form": [
			Vector2(0,0),
			Vector2(0,1),
			Vector2(0,2),
			Vector2(1,0),
			Vector2(-1,0),
			Vector2(0,-1)
		]
	}
]

func _ready() -> void:
	add_to_group("board")
	set_board()

func set_board() -> void:
	for column in range(WIDTH):
		for row in range(HEIGHT):
			if _is_within_bounds(Vector2i(column, row)):
				set_cell(Vector2(column, row), 0, Vector2i(0, 1), 0)

func placing(on_placed):
	is_placing = true;
	
	dice_placed.connect(on_placed);

func _process(_delta: float) -> void:
	var center_tile = get_selected_tile()
	var selected_form = FORMS[selected_form_index];

	if(is_placing):
		if(center_tile != prev_selected_tile || selected_form_index != prev_selected_form_index):
			for prev_cell in select_dice_cells:
				set_cell(prev_cell, 0, Vector2i(0, 1), 0)
				
			var place_cell = Vector2i(1,0);
			
			for cell_form in selected_form["form"]:
				var cell_coord = local_to_map(to_local(center_tile) + (cell_form * 32))
				
				if(_is_within_play_bounds(cell_coord)):
					prev_selected_tile = center_tile;
					prev_selected_form_index = selected_form_index
					select_dice_cells.push_back(cell_coord)
					set_cell(cell_coord, 0, place_cell, 0)
		
		if(Input.is_action_just_pressed("move_right")):
			prev_selected_form_index = selected_form_index
			if(selected_form_index == (FORMS.size() - 1)):
				selected_form_index = 0;
			else:
				selected_form_index += 1

		if(Input.is_action_pressed("move_left")):
			prev_selected_form_index = selected_form_index
			if(selected_form_index == 0):
				selected_form_index = (FORMS.size() - 1);
			else:
				selected_form_index -= 1;

		if(Input.is_action_just_pressed("confirm")):
			var form = selected_form["form"].map(func(cell_form):  return local_to_map(to_local(get_selected_tile()) + (cell_form * 32)))

			if(!form.all(_is_within_play_bounds)):
				return
			
			dice_limit += selected_form["height"]
			
			var selected_dice = stage.get_dice_on_hand()
			
			place(selected_dice, form);
			
			select_dice_cells.clear();
			is_placing = false;
			prev_selected_tile = null;
			
			dice_placed.emit();


func place(selected_dice, form):
	var selected_tile = get_selected_tile();
	var dice_scene = preload("res://src/scenes/dice.tscn")
	
	build_dice(selected_tile, form)
	summon(selected_dice, selected_tile)

func build_dice(dice_center, form):
	var dice_face = Vector2i(1,1)

	for cell_form in form:
		path.push_back(cell_form)
		set_cell(cell_form, 0, dice_face, 0)

func summon(dice, summon_target_position):
	var summon_scene = preload("res://src/scenes/summon.tscn")
	var summon_instance = summon_scene.instantiate();
	
	summon_instance.init(dice.summon);
	
	units.add_ally(summon_instance, summon_target_position)
	add_child(summon_instance)
	
	return summon_instance;

func on_possible_moves(tile, move):
	var possible_moves = _calculate_possible_moves(to_local(tile.position), move);
	possible_move_cells = possible_moves;
	
	_highlight_summon_possible_moves(possible_moves);
	
	return possible_moves.map(_possible_moves_to_global);

func reset_possible_moves():
	for cell in possible_move_cells:
		set_cell(cell["tile"], 0, Vector2i(1,1));
	possible_move_cells = [];

func _calculate_possible_moves(position, tile_moves):
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

	for direction in directions.values():
		var moves = _calculate_moves_in_direction(position, tile_moves, direction)
		
		possible_moves.append_array(moves);
	
	return possible_moves;

func _calculate_moves_in_direction(current_tile: Vector2, moves: int, direction: Vector2):
	var path = [];
	var next_tile = current_tile + direction;
	
	var moves_left = moves;
	
	while _is_tile_a_path(next_tile) and moves_left > 0:
		path.append({
			"tile": local_to_map(next_tile),
			"distance": (moves - moves_left) + 1
		});
		moves_left -= 1
		next_tile += direction;
	
	return path;

func _highlight_summon_possible_moves(possible_moves):
	for move in possible_moves:
		set_cell(move["tile"], 0, Vector2i(0,0));

func get_allies_units():
	return units.get_allies();

func get_all_units():
	return units.get_all_units();

func get_enemies():
	return units.get_enemies();

func get_allies():
	return units.get_allies();

func get_selected_tile():
	var tile = local_to_map(get_global_mouse_position())
	return map_to_local(tile)

func _is_tile_a_path(tile_coord):
	var cell_atlas_coords = get_cell_atlas_coords(local_to_map(tile_coord))
	return _is_within_bounds(cell_atlas_coords) and cell_atlas_coords == Vector2i(1,1)

func _possible_moves_to_global(possible_moves):
	return {
		"tile": to_global(map_to_local(possible_moves["tile"])),
		"distance": possible_moves["distance"]
	}

func _is_within_play_bounds(tile):
	return _is_within_bounds(tile) and tile.y > (HEIGHT - dice_limit); 

func _is_within_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.x < WIDTH and tile.y >= 0 and tile.y < HEIGHT;
