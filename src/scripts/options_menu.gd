extends Control


func add_options(title, options):
	var menu : PopupMenu = $menu/PopupMenu;
	menu.title = title;
	for option_index in range(options.size()):
		var option = options[option_index];
		menu.add_item(option.label, option_index);
