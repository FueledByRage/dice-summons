extends Node

enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING }

var state = States.IDLE

@onready var tile_map_layer = $TileMap;
@onready var units = $Units;

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
				#var mouse_position = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
				#if mouse_position in tile_map_layer.possible_move_cells:
					#var summon = units.summons_map[0].node
					#tile_map_layer.move_summon(summon, mouse_position)
					#state = States.IDLE
				pass
		States.IDLE:
			if event.is_action_pressed("placing"):
				state = States.PLACING
				tile_map_layer.to_placing();
			if event.is_action_pressed('select'):
				_to_selecting();
		States.SELECTING:
			if event.is_action_pressed("move_right"):
				if select_target_index + 1 >= targets.size():
					select_target_index = 0
				else:
					select_target_index += 1
				move_arrow_to_on_focus();
			elif event.is_action_pressed("move_left") and select_target_index != 0:
				select_target_index -= 1
				move_arrow_to_on_focus();
			elif event.is_action_pressed("confirm"):
				on_confirm()

func on_confirm():
	var selected = targets[select_target_index]
	$select_arrow.queue_free();
	if state == States.SELECTING:
		display_summon_options(selected.node)
		state = States.ATTACKING
	elif state == States.ATTACKING:
		print("executing " + selected.name)

func _to_selecting():
	targets = units.allies_units;
	state = States.SELECTING;
	if targets.size() > 0:
		display_target_on_focus();

func _to_atacking(targets):
	state = States.ATTACKING;
	display_target_on_focus();

func _to_idle():
	state = States.IDLE

func display_target_on_focus():
	var on_focus = targets[select_target_index];
	var select_arrow = preload('res://src/scenes/select_arrow.tscn').instantiate();
	var on_focus_position_arrow_position = on_focus.global_local + Vector2(0, -15);
	select_arrow.global_position = on_focus_position_arrow_position;
	
	add_child(select_arrow);

func move_arrow_to_on_focus():
	var on_focus = targets[select_target_index];
	var select_arrow = $select_arrow;
	var on_focus_position_arrow_position = on_focus.global_local + Vector2(0, -15);
	select_arrow.global_position = on_focus_position_arrow_position;

func display_summon_options(summon):
	var menu = preload("res://src/scenes/menu.tscn").instantiate();
	
	menu.global_position = summon.global_position + Vector2(5, -5);
	menu.add_options("Speels", summon.spells);
	add_child(menu);

func on_select_menu_option(option):
	pass

func cast(spell):
	var targets 
	if(spell.target_type == "all"):
		targets = units.get_all_units();
		pass
	elif(spell.target_type == "allies"):
		targets = units.allies_units;
		pass
	elif(spell.target_type == 'enemies'):
		targets = units.enemies_units;
		pass
	elif(spell.target_type == 'own'):
		pass
	_to_atacking(targets);

func execute_spell(spell, target):
	pass;
