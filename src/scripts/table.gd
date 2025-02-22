extends Node

signal select

enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING, ON_MOVING }
var state = States.IDLE

@onready var tile_map_layer = $TileMap;
@onready var units = $Units;
@onready var select_arrow = $Select_arrow;


var targets = [];
var select_target_index = 0;
var casted_spell
var summon_on_move

func _input(event: InputEvent) -> void:
	match state:
		States.PLACING:
			if event.is_action_pressed("place"):
				tile_map_layer.place()
		States.MOVING:
			if event.is_action_released("confirm"):
				on_confirm();
		States.IDLE:
			if event.is_action_pressed("placing"):
				tile_map_layer.placing(_to_idle);
				state = States.PLACING
			if event.is_action_pressed('select'):
				_to_selecting();
			if event.is_action_pressed("move"):
				_to_moving();
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
		States.ATTACKING:
			if event.is_action_pressed("confirm"):
				on_confirm();
		States.ON_MOVING:
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
				select.emit();

func on_confirm():
	var selected = targets[select_target_index]
	select_arrow.visible = false;
	if state == States.SELECTING:
		display_summon_options(selected.value.node)
		state = States.ATTACKING
	elif state == States.ATTACKING:
		select.emit(selected.value);
		return
	select.emit(selected.value);

func _to_selecting():
	targets = units.allies_units.map(_unit_to_option)
	state = States.SELECTING;
	
	if targets.size() > 0:
		display_target_on_focus();

func _to_atacking(targets):
	$Menu.queue_free();
	state = States.ATTACKING;
	select.connect(execute_spell, 4)
	
	display_target_on_focus();

func _to_moving():
	targets = units.map(_unit_to_option);
	select.connect(select_to_move, 4);
	display_target_on_focus();
	state = States.MOVING;

func _unit_to_option(unit):
	return {
		'position': unit.global_local,
'		value': unit
	}

func select_to_move(selected_summon):
	targets = tile_map_layer.move_summon(selected_summon).map(_position_to_option)
	display_target_on_focus();
	select.connect(move_summon.bind(selected_summon), 4)
	state = States.ON_MOVING;

func _position_to_option(position):
	return {
		'global_position': position,
		'value': position,
	}

func move_summon(summon):
	var selected_tile = targets[select_target_index];
	
	summon.node.global_position = selected_tile.value;
	tile_map_layer.reset_possible_moves();
	select_arrow.visible = false;
	
	_to_idle()

func _to_idle():
	state = States.IDLE

func display_target_on_focus():
	var on_focus_position = get_selected_option_property('global_position');
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15);
	
	select_arrow.global_position = on_focus_position_arrow_position;
	
	select_arrow.visible = true;

func move_arrow_to_on_focus():
	var on_focus_position = get_selected_option_property('global_position');
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15);
	select_arrow.global_position = on_focus_position_arrow_position;

func display_summon_options(summon):
	var menu = preload("res://src/scenes/menu.tscn").instantiate();
	
	menu.global_position = summon.global_position + Vector2(5, -5);
	menu.add_options("Speels", summon.spells, cast);
	add_child(menu);

func on_select_menu_option(option):
	pass

func cast(spell):
	casted_spell = spell;
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

func execute_spell(target):
	target.node.apply_change_on_life(casted_spell.life_effect);
	casted_spell = null;
	_to_idle()
	pass;
	
func get_selected_option_property(property):
	return targets[select_target_index][property]
