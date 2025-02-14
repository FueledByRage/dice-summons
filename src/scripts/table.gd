extends Node

enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING }

var state = States.IDLE

@onready var tile_map_layer = $TileMap;

var targets = [];
var select_target_index = 0;

func _input(event: InputEvent) -> void:
	match state:
		States.PLACING:
			if event.is_action_pressed("place"):
				tile_map_layer.place()
				_to_idle();
		States.MOVING:
			if event.is_action("left_click"):
				var mouse_position = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
				if mouse_position in tile_map_layer.possible_move_cells:
					var summon = tile_map_layer.summons_map[0].node
					tile_map_layer.move_summon(summon, mouse_position)
					state = States.IDLE
		States.IDLE:
			if event.is_action_pressed("placing"):
				state = States.PLACING
				tile_map_layer.to_placing();
			if event.is_action_pressed('select'):
				_to_selecting();
		States.SELECTING:
			if event.is_action_pressed("move_right"):
				if select_target_index >= targets.size():
					select_target_index = 0
				else:
					select_target_index += 1
			elif event.is_action_pressed("move_left") and select_target_index != 0:
				select_target_index -= 1
			elif event.is_action_pressed("confirm"):
				on_confirm()

func on_confirm():
	var selected = targets[select_target_index]
	if state == States.SELECTING:
		tile_map_layer.display_summon_options(selected.node)
		tile_map_layer.select_targets = selected.node
		state = States.ATTACKING
	elif state == States.ATTACKING:
		print("executing " + selected.name)

func _to_selecting():
	targets = tile_map_layer.summons_map;
	state = States.SELECTING;
	if targets.size() > 0:
		display_target_on_focus();
	pass

func _to_idle():
	#var menu = preload("res://src/scenes/options_menu.tscn").instantiate();
	#var UI = $UI;
	#menu.add_options("Summons", tile_map_layer.summons_map);
	#UI.add_child(menu);
	state = States.IDLE

func display_target_on_focus():
	var on_focus = targets[select_target_index];
	var select_arrow = preload('res://src/scenes/select_arrow.tscn').instantiate();
	var on_focus_position_arrow_position = on_focus.global_local + Vector2(0, -15);
	select_arrow.global_position = on_focus_position_arrow_position;
	
	add_child(select_arrow);
