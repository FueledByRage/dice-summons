extends Node

signal target_selected

enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING, ON_MOVING, CASTING }
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
			if event.is_action_released("place"):
				tile_map_layer.place()
				_to_idle();

		States.MOVING:
			handle_selecting_options(event);

		States.IDLE:
			if event.is_action_released("placing"):
				tile_map_layer.placing(_to_idle);
				state = States.PLACING
			if event.is_action_released('select'):
				_to_selecting();
			if event.is_action_released("move"):
				_to_moving();

		States.SELECTING:
			handle_selecting_options(event);

		States.ATTACKING:
			if event.is_action_released("confirm"):
				_on_confirm();

		States.ON_MOVING:
			handle_selecting_options(event);

		States.CASTING:
			handle_selecting_options(event);

func handle_selecting_options(event):
		if event.is_action_released("move_right"):
			_next_target();
		elif event.is_action_released("move_left") and select_target_index != 0:
			_previous_target();
		elif event.is_action_released("confirm"):
				_on_confirm();

func _next_target():
	select_target_index = (select_target_index + 1) % targets.size()
	move_arrow_to_on_focus()

func _previous_target():
	if select_target_index > 0:
		select_target_index -= 1
		move_arrow_to_on_focus()

func _on_confirm():
	var selected = get_selected_option();
	
	select_arrow.visible = false;
	
	target_selected.emit(selected);
	
	select_target_index = 0;

func get_selected_option():
	if targets.size() > 0:
		return targets[select_target_index]

func get_selected_option_property(property):
	if targets.size() > 0:
		return targets[select_target_index][property]

func _position_to_option(position):
	return {
		'position': position,
		'value': position,
	}

func _unit_to_option(unit):
	return {
		'position': unit.global_local,
		'value': unit
	}

func move_summon(selected_tile):
	summon_on_move.node.global_position = selected_tile.value;
	
	tile_map_layer.reset_possible_moves();
	select_arrow.visible = false;
	
	summon_on_move = null
	_to_idle()

func display_target_on_focus():
	var on_focus_position = get_selected_option().position;
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15);
	
	select_arrow.move_to(on_focus_position_arrow_position);
	
	select_arrow.visible = true;

func move_arrow_to_on_focus():
	var on_focus_position = get_selected_option().position
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15);
	select_arrow.move_to(on_focus_position_arrow_position);

func display_summon_options(summon):
	var menu = preload("res://src/scenes/menu.tscn").instantiate();
	
	menu.global_position = summon.global_position + Vector2(5, -5);
	menu.add_options("Speels", summon.spells, cast);
	add_child(menu);

func cast(spell):
	casted_spell = spell;
	if(spell.target_type == "all"):
		targets = units.get_all_units().map(_unit_to_option)
	elif(spell.target_type == "allies"):
		targets = units.allies_units.map(_unit_to_option)
	elif(spell.target_type == 'enemies'):
		targets = units.enemies_units.map(_unit_to_option)
	elif(spell.target_type == 'own'):
		pass
	_to_selecting_target();

func execute_spell(target):
	if(casted_spell):
		target.value.node.apply_change_on_life(casted_spell.life_effect);
		casted_spell = null;
	_to_idle()

func _to_idle():
	state = States.IDLE

func _to_selecting():
	var allies_units = units.allies_units.map(_unit_to_option);
	
	if allies_units.size() > 0:
		targets = allies_units;
		state = States.SELECTING;
		target_selected.connect(_to_attacking, 4);
		display_target_on_focus();

func _to_attacking(selected):
	display_summon_options(selected.value.node);
	state = States.ATTACKING;
	target_selected.connect(_to_selecting_target, 4);

func _to_selecting_target():
	if has_node("Menu"):
		$Menu.queue_free()

	target_selected.connect(execute_spell, 4);
	
	state = States.CASTING;
	
	display_target_on_focus();

func _to_on_moving(selected_summon):
	summon_on_move = selected_summon.value;
	
	targets = tile_map_layer.on_possible_moves(selected_summon, 5).map(_position_to_option);
	
	display_target_on_focus();
	
	target_selected.connect(move_summon, 4);
	
	state = States.ON_MOVING;

func _to_moving():
	targets = units.allies_units.map(_unit_to_option);
	
	target_selected.connect(_to_on_moving, 4);
	
	display_target_on_focus();
	
	state = States.MOVING;
