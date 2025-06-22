extends CenterContainer

var label : Label
var buttons_container : HBoxContainer

func init(config):
	label = $MarginContainer/background_texture/label_margin/content/text
	buttons_container = $MarginContainer/background_texture/label_margin/content/buttons
	
	label.text = config.message
	
	for option in config.options:
		var button = Button.new()
		
		button.text = option['text']
		button.pressed.connect(option['action'])
		buttons_container.add_child(button)
