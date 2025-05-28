extends CanvasLayer

@onready var points_types = get_parent().Points;
@onready var center = $center;
@onready var points_display = $points;

func set_points(points: Dictionary):
	var keys = points.keys();
	for key in keys:
		var points_container = VBoxContainer.new()
		points_container.name = points_types.keys()[key];
		
		var point = points[key].value;
		var maximum_point = points[key].maximum;
		
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 40)
		label.text = str(point) + "/" + str(maximum_point);
		
		points_container.add_child(label);
		points_display.add_child(points_container);

func change_point(point_type, modifier):
	var points_container = points_display.get_node(point_type);
	var label : Label = points_container.get_child(0)
	
	var values = label.text.split("/")
	var new_value = float(values[0]) + modifier
	
	label.text = str(new_value) + "/" + str(values[1])

func roll_dices(on_roll_completed):
	var roll_controller = load("res://src/scenes/roll_controller.tscn").instantiate()
	
	roll_controller.setup(3)
	center.add_child(roll_controller)
	
	roll_controller.roll(on_roll_completed)

#To - Do WRITE THE DICE LOGIC UPSTAIR
func display_dices_menu(dices, on_selected):
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	
	menu.init(dices.map(func (dice): return dice_to_option(dice, on_selected)))
	center.add_child(menu)

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
	center.add_child(menu)

func show_menu(options):
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	
	menu.init(options)
	
	center.add_child(menu)
