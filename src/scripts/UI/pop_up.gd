extends MarginContainer

@onready var label : Label = $background_texture/label_margin/content/text
@onready var buttons_container = $background_texture/label_margin/content/buttons

func init(config):
	label.text = config['message']
	
	for option in config['options']:
		var button = Button.new()
		
		button.text = option['text']
		button.pressed.connect(option['action'])
