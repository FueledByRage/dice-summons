extends Node2D

# === Sinais ===
signal target_selected

# === Constantes e Enums ===
enum States { ROLLING, DRAW_PHASE, SELECTING_SPELL, PLACING, IDLE, SELECTING, MOVING, ON_MOVING, CASTING_SPELL }

# === Variáveis de Estado ===
var state = States.IDLE
var targets = []
var select_target_index = 0
var casted_spell
var summon_on_move
var dices_on_hand = []
var dice_on_hand

var points = {
	"summon_points": 0,
	"move_points": 0,
	"energy_points": 0,
}

# === Referências para Nós ===
@onready var table = $TileMap
@onready var units = $TileMap/Units
@onready var select_arrow = $Select_arrow
@onready var dices_module = $dices_module
@onready var camera = $Camera2D

# =====================================================================
# === INICIALIZAÇÃO ==================================================
# =====================================================================

func _ready() -> void:
	_to_roll()

# =====================================================================
# === ENTRADA DO USUÁRIO (INPUT) =====================================
# =====================================================================

func _input(event: InputEvent) -> void:
	match state:
		States.IDLE:
			if event.is_action_released("select"):
				to_selecting_attacking_summon()
			elif event.is_action_released("move"):
				to_moving()
			elif event.is_action_pressed("placing"):
				to_placing()

		States.SELECTING_SPELL:
			if event.is_action_released("confirm"):
				_on_confirm()

	if state in [States.SELECTING, States.MOVING, States.ON_MOVING, States.CASTING_SPELL]:
		handle_selecting_options(event)

# =====================================================================
# === LÓGICA DE SELEÇÃO ===============================================
# =====================================================================

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
	select_target_index = 0
	
	target_selected.emit(selected)

func get_selected_option():
	if targets.size() > 0:
		return targets[select_target_index]

func get_selected_option_property(property):
	if targets.size() > 0:
		return targets[select_target_index][property]

func _position_to_option(position):
	return {
		'position': position["tile"],
		'distance': position["distance"]
	}

func _unit_to_option(unit):
	return {
		'position': unit.global_position,
		'value': unit
	}

# =====================================================================
# === MÁQUINA DE ESTADOS =============================================
# =====================================================================

func _to_roll():
	state = States.ROLLING
	roll()

func _to_draw_phase():
	state = States.DRAW_PHASE


func _to_idle():
	targets.clear()
	select_target_index = 0
	state = States.IDLE
	
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	var has_units = units.has_units()
	var options = [
		{
			"label": "Attack",
			"icon": "res://icon.svg",
			"selectable": has_units,
			"action": to_selecting_attacking_summon,
		},
		{
			"label": "Move",
			"icon": "res://icon.svg",
			"selectable": has_units,
			"action": to_moving,
		},
		{
			"label": "Summon",
			"icon": "res://icon.svg",
			"selectable": points["summon_points"] > 0,
			"action": to_placing,
		},
		{
			"label": "Pass Turn",
			"icon": "res://icon.svg",
			"selectable": true,
			"action": _to_roll
			
		}
	]

	menu.init(options)
	camera.add_child(menu)

func to_placing():
	state = States.PLACING
	table.placing(_to_idle)
	points["summon_points"] -= dice_on_hand["cost"]

# =====================================================================
# === FLUXO DE ATAQUE / FEITIÇO ======================================
# =====================================================================

func to_selecting_attacking_summon():
	var allies_units_options = table.get_allies_units().map(_unit_to_option)
	if allies_units_options.size() > 0:
		targets = allies_units_options
		target_selected.connect(_to_selecting_spell, CONNECT_ONE_SHOT)
		state = States.SELECTING
		display_target_on_focus()

func _to_selecting_spell(selected):
	display_summon_options(selected.value)
	state = States.SELECTING_SPELL
	target_selected.connect(_to_casting_spell, CONNECT_ONE_SHOT)

func _to_casting_spell():
	target_selected.connect(execute_spell, CONNECT_ONE_SHOT)
	state = States.CASTING_SPELL
	display_target_on_focus()

func cast(spell):
	casted_spell = spell
	if spell.target_type == "all":
		targets = table.get_all_units().map(_unit_to_option)
	elif spell.target_type == "allies":
		targets = table.get_allies_units().map(_unit_to_option)
	elif spell.target_type == "enemies":
		targets = table.get_allies_units().map(_unit_to_option)
	elif spell.target_type == "own":
		pass
	else:
		targets = []
	_to_casting_spell()

func execute_spell(target):
	if casted_spell:
		target.value.apply_change_on_life(casted_spell.life_effect)
		casted_spell = null
	_to_idle()

# =====================================================================
# === MOVIMENTO ======================================================
# =====================================================================

func to_moving():
	targets = table.get_allies().map(_unit_to_option)
	target_selected.connect(_to_on_moving, CONNECT_ONE_SHOT)
	display_target_on_focus()
	state = States.MOVING

func _to_on_moving(selected_summon):
	summon_on_move = selected_summon.value
	targets = table.on_possible_moves(selected_summon, points["move_points"]).map(_position_to_option)
	
	display_target_on_focus()
	
	target_selected.connect(move_summon, CONNECT_ONE_SHOT)
	state = States.ON_MOVING

func move_summon(selected_tile_data):
	summon_on_move.global_position = selected_tile_data.position
	
	table.reset_possible_moves()
	''
	select_arrow.visible = false
	summon_on_move = null
	points["move_points"] -= selected_tile_data["distance"]
	_to_idle()

# =====================================================================
# === DADOS ==========================================================
# =====================================================================

func draw_dices():
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	dices_on_hand = dices_module.draw_dices(3);
	
	menu.init(dices_on_hand.map(dice_to_option))
	camera.add_child(menu)

func on_dice_selected(selected_dice):
	var no_selected_dices = dices_on_hand.filter(func(dice): return dice['id'] != selected_dice['id'])
	
	dices_module.put_dices(no_selected_dices)
	dice_on_hand = selected_dice
	dices_on_hand = []
	_to_idle();


func dice_to_option(dice):
	return {
		"label": dice["label"],
		"subtitle": "⚡" + " " + str(dice["cost"]),
		"icon": dice["icon"],
		"selectable": true,
		"action": func(): on_dice_selected(dice),
	}

func get_dice_on_hand():
	return dice_on_hand

func roll():
	var roll_controller = load("res://src/scenes/roll_controller.tscn").instantiate()
	roll_controller.setup(3)
	camera.add_child(roll_controller)
	roll_controller.roll(on_roll_completed)

func on_roll_completed(results):
	points["summon_points"] += results[0]
	points["move_points"] += results[1]
	points["energy_points"] += results[2]
	draw_dices()

# =====================================================================
# === VISUAL/UI ======================================================
# =====================================================================

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
	menu.add_options("Spells", summon.SPELLS, cast)
	add_child(menu)
