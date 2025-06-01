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

func change_point(point_type, new_value):
	var points_container = points_display.get_node(point_type);
	
	if(points_container == null):
		return;
	
	var label : Label = points_container.get_child(0)
	
	var values = label.text.split("/")
	
	label.text = str(new_value) + "/" + str(values[1])

# To Do remove it to a new service or component
func roll_dices(on_roll_completed):
	var roll_controller = load("res://src/scenes/roll_controller.tscn").instantiate()
	
	roll_controller.setup(3)
	center.add_child(roll_controller)
	
	roll_controller.roll(on_roll_completed)

func show_options(menu_title, options, on_selected):
	var menu = preload("res://src/scenes/menu.tscn").instantiate()
	menu.add_options(menu_title, options, on_selected)
	center.add_child(menu)

func show_menu(options):
	var menu = load("res://src/scenes/UI/menu.tscn").instantiate()
	
	menu.init(options)
	
	center.add_child(menu)
