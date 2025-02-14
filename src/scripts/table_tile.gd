extends TileMapLayer

var WIDTH = 12
var HEIGHT = 20

var maped_table: Dictionary = {}

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
	summons_map.append({
		"node": summon,
		"name": summon.name,
		"label": summon.name, 
		"local": to_local(summon.global_position),
		"global_local": summon.global_position
	})

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
