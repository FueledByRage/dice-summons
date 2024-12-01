extends TileMapLayer

var WIDTH = 12;
var HEIGHT = 20;

var maped_table : Dictionary = {};

var selected_tile;
var placing = false;
var moving = false;
var placing_dice;

var path = [];
var summons_map = [];

var possible_move_cells = [];

func _ready() -> void:
	add_to_group('table');
	set_table();

func _process(delta: float) -> void:
		if(placing):
			set_selected_tile();
			placing_dice.global_position = selected_tile;
			if(Input.is_action_just_pressed("place")):
				place();
				pass
		else:
			if(Input.is_action_pressed("placing")):
				to_placing();
		if(Input.is_action_just_pressed("move") && !moving):
			display_possible_paths();
			moving = true;

func _input(event: InputEvent) -> void:
	if(event.is_action("left_click") && moving):
		var mouse_position = local_to_map(get_local_mouse_position());
		if(mouse_position in possible_move_cells):
			var summon = summons_map[0];
			summon.node.global_position = map_to_local(mouse_position);
			moving = false;
func set_table() -> void:
	for column in WIDTH:
		for row in HEIGHT:
			var tile = Vector2(column, row);
			var tileRect = Vector2i(0,1);
			
			set_cell(tile, 0, tileRect, 0);

func set_selected_tile() -> void:
	var tile = local_to_map(get_global_mouse_position());
	selected_tile = map_to_local(tile);

func to_placing():
	var placing_dice_scene = preload("res://src/scenes/place_dice.tscn");
	var placing_dice_instance = placing_dice_scene.instantiate();
	
	add_child(placing_dice_instance);
	
	placing_dice = placing_dice_instance;
	
	placing = true;

func place():
	var dice_scene = preload("res://src/scenes/dice.tscn");
	var dice_instance = dice_scene.instantiate();
	
	placing_dice.queue_free();
	build_dice(selected_tile);
	summon();
	
	placing = false;

func place_dice(cells_coords):
	var dice_face = Vector2i(1,1);
	for cell in cells_coords:
		var cell_coord = local_to_map(to_global(cell));
		set_cell(cell_coord, 0, dice_face, 0);
		path.push_back(cell_coord);

func build_dice(dice_center: Vector2):
	var dice_face = Vector2i(1,1);

	var form = [
		Vector2(0,0),
		Vector2(0, -1),
		Vector2(0, -2),
		Vector2(-1,0),
		Vector2(1,0),
		Vector2(0, 1)
	];
	
	for cell_form in form:
		var cell_coord = local_to_map(to_local(dice_center) + (cell_form * 32));
		path.push_back(cell_coord);
		set_cell(cell_coord, 0, dice_face, 0);

func summon():
	var summon_scene = preload("res://src/scenes/summon.tscn");
	var summon_instance = summon_scene.instantiate();
	
	var summon_local = to_local(selected_tile);
	
	summon_instance.global_position = summon_local;
	
	add_child(summon_instance);
	
	add_summon_to_path(summon_instance);

func add_summon_to_path(summon):
	summons_map.append({
		"node": summon,
		"name": summon.name,
		"local": to_local(summon.global_position),
	});

func display_possible_paths():
	var summon = summons_map[0];
	possible_move_cells = get_possible_moves(summon.local, 3);
	
	for cell in possible_move_cells:
		set_cell(cell, 0, Vector2(0,0),0);

func get_possible_moves(summon_position: Vector2, move_range: int) -> Array:
	var possible_moves = [];
	var visited = [];
	
	var start_tile = local_to_map(summon_position);
	
	var queue = [{ "tile": start_tile, "distance": 0 }];
	
	while queue.size() > 0:
		var current = queue.pop_front();
		var current_tile = current["tile"];
		var current_distance = current["distance"];
		
		if current_distance <= move_range and current_tile not in visited:
			visited.append(current_tile);
			possible_moves.append(current_tile)
			
			var neighbors = [
				current_tile + Vector2i(0, -1), # up
				current_tile + Vector2i(0, 1),  # down
				current_tile + Vector2i(-1, 0), # left
				current_tile + Vector2i(1, 0)   # right
			];
			
			for neighbor in neighbors:
				if neighbor in path and neighbor not in visited:
					queue.append({ "tile": neighbor, "distance": current_distance + 1 })
	return possible_moves
