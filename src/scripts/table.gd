extends Node2D

# TO-DO - Break it in small pieces

# === Sinais ===
signal target_selected


# === Constantes e Enums ===
enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING, ON_MOVING, CASTING }
const DISCONECT_SIGNAL_ON_USE = 4


# === Variáveis de Estado ===
var state = States.IDLE
var targets = []
var select_target_index = 0
var casted_spell
var summon_on_move
var dices_on_hand = []
var dice_on_hand


# === Referências para Nós ===
@onready var table = $TileMap
@onready var units = $Units
@onready var select_arrow = $Select_arrow
@onready var dices_module = $dices_module


# === Ciclo Principal ===
func _input(event: InputEvent) -> void:
	match state:
		States.IDLE:
			if event.is_action_released("select"):
				_to_selecting()
			elif event.is_action_released("move"):
				_to_moving()
			elif event.is_action_pressed("placing"):
				_selecting_dices()

		States.ATTACKING:
			if event.is_action_released("confirm"):
				_on_confirm()

	if state in [States.SELECTING, States.MOVING, States.ON_MOVING, States.CASTING]:
		handle_selecting_options(event)


# === Manipulação de Seleção ===
func handle_selecting_options(event):
	if event.is_action_released("move_right"):
		_next_target()
	elif event.is_action_released("move_left") and select_target_index != 0:
		_previous_target()
	elif event.is_action_released("confirm"):
		_on_confirm()

func _next_target():
	select_target_index = (select_target_index + 1) % targets.size()
	move_arrow_to_on_focus()

func _previous_target():
	if select_target_index > 0:
		select_target_index -= 1
		move_arrow_to_on_focus()

func _on_confirm():
	var selected = get_selected_option()
	select_arrow.visible = false
	target_selected.emit(selected)
	select_target_index = 0


# === Obtenção de Opções Selecionadas ===
func get_selected_option():
	if targets.size() > 0:
		return targets[select_target_index]

func get_selected_option_property(property):
	if targets.size() > 0:
		return targets[select_target_index][property]

func _position_to_option(position):
	return {
		'position': position,
		'value': position
	}

func _unit_to_option(unit):
	return {
		'position': unit.global_position,
		'value': unit
	}


# === Estados ===
func _to_idle():
	state = States.IDLE

func _to_selecting():
	var allies_units_options = table.get_allies_units().map(_unit_to_option)
	if allies_units_options.size() > 0:
		targets = allies_units_options
		target_selected.connect(_to_attacking, DISCONECT_SIGNAL_ON_USE)
		state = States.SELECTING
		display_target_on_focus()

func _to_attacking(selected):
	display_summon_options(selected.value)
	state = States.ATTACKING
	target_selected.connect(_to_selecting_target, DISCONECT_SIGNAL_ON_USE)

func _to_selecting_target():
	if has_node("Menu"):
		$Menu.queue_free()

	target_selected.connect(execute_spell, DISCONECT_SIGNAL_ON_USE)
	state = States.CASTING
	display_target_on_focus()

func _to_on_moving(selected_summon):
	summon_on_move = selected_summon.value
	targets = table.on_possible_moves(selected_summon, 5).map(_position_to_option)
	display_target_on_focus()
	target_selected.connect(move_summon, DISCONECT_SIGNAL_ON_USE)
	state = States.ON_MOVING

func _to_moving():
	targets = table.get_allies().map(_unit_to_option)
	target_selected.connect(_to_on_moving, DISCONECT_SIGNAL_ON_USE)
	display_target_on_focus()
	state = States.MOVING


# === Funcionalidades de Magia ===
func cast(spell):
	casted_spell = spell
	if spell.target_type == "all":
		targets = table.get_all_units().map(_unit_to_option)
	elif spell.target_type == "allies":
		targets = table.allies_units.map(_unit_to_option)
	elif spell.target_type == "enemies":
		targets = table.enemies_units.map(_unit_to_option)
	elif spell.target_type == "own":
		pass
	_to_selecting_target()

func execute_spell(target):
	if casted_spell:
		target.value.apply_change_on_life(casted_spell.life_effect)
		casted_spell = null
	_to_idle()


# === Funcionalidades de Movimento ===
func move_summon(selected_tile):
	summon_on_move.node.global_position = selected_tile.value
	table.reset_possible_moves()
	select_arrow.visible = false
	summon_on_move = null
	_to_idle()


# === Seleção de Dados ===
func on_dice_selected(selected_dice):
	var no_selected_dices = dices_on_hand.filter(func(dice): return dice['id'] != selected_dice['id'])

	dice_on_hand = selected_dice
	dices_on_hand = []

	table.placing(_to_idle)
	state = States.PLACING
	dices_module.put_dices(no_selected_dices)


# === UI e Visuals ===
func display_target_on_focus():
	var on_focus_position = to_local(get_selected_option().position)
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15)
	select_arrow.move_to(on_focus_position_arrow_position)
	select_arrow.visible = true

func move_arrow_to_on_focus():
	var on_focus_position = get_selected_option().position
	var on_focus_position_arrow_position = on_focus_position + Vector2(0, -15)
	select_arrow.move_to(on_focus_position_arrow_position)

func display_summon_options(summon):
	var menu = preload("res://src/scenes/menu.tscn").instantiate()
	menu.global_position = summon.global_position + Vector2(5, -5)
	menu.add_options("Spells", summon.spells, cast)
	add_child(menu)
	
func _selecting_dices():
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	dices_on_hand = dices_module.draw_dices(3)
	
	menu.init(dices_on_hand, on_dice_selected)
	menu.global_position = get_local_mouse_position()
	
	add_child(menu)

func get_dice_on_hand():
	return dice_on_hand;
