extends VBoxContainer


var option;

func init(option_content):
	var icon = $icon;
	var label = $label;
	
	var texture = Image.load_from_file(option_content.icon);
	
	icon.scale = Vector2(0.5, 0.5)
	
	icon.texture =  ImageTexture.new().create_from_image(texture)
	label.text = option_content.label;
	
	option = option_content;
