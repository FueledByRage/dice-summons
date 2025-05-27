extends CanvasLayer

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func show_idle_menu():
	pass

func roll_dices(on_roll_completed):
	var roll_controller = load("res://src/scenes/roll_controller.tscn").instantiate()
	
	roll_controller.setup(3)
	add_child(roll_controller)
	
	roll_controller.roll(on_roll_completed)

func display_dices_menu(dices, on_selected):
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	
	menu.init(dices.map(func (dice): return dice_to_option(dice, on_selected)))
	add_child(menu)

func dice_to_option(dice, on_selected: Callable):
	return {
		"label": dice["label"],
		"subtitle": "⚡" + " " + str(dice["cost"]),
		"icon": dice["icon"],
		"selectable": true,
		"action": func(): on_selected.call(dice),
	}

func show_options(menu_title, options, on_selected):
	var menu = preload("res://src/scenes/menu.tscn").instantiate()
	menu.add_options(menu_title, options, on_selected)
	add_child(menu)

func show_menu(options):
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	
	menu.init(options)
	
	add_child(menu)
