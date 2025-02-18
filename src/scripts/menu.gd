extends Control

func add_options(title: String, options, on_pressed: Callable):
	for option_index in range(options.size()):
		var buttons = $MenuBox/ButtonsContainer;
		var option = options[option_index];
		
		var button = Button.new();
		button.text = option.name;
		buttons.add_child(button);
		button.connect('pressed', on_pressed.bind(option))
