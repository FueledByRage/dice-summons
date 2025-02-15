extends Control

	
func add_options(title, options):
	$menu.title = title;
	var pop_up_menu : PopupMenu = $menu/PopupMenu;
	for option_index in range(options.size()):
		var option = options[option_index];
		pop_up_menu.add_item(option.name, option_index);
