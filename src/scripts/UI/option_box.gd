extends VBoxContainer


var option;
var action;

func init(option_content : Dictionary):
	var label = $label;
	var icon = $icon;
	var subtitle = $subtitle;
	var texture = Image.load_from_file(option_content.icon);
	
	
	label.text = option_content.label;
	icon.scale = Vector2(0.5, 0.5)
	action = option_content.action;
	
	if(option_content.has("subtitle") && option_content.subtitle != ""):
		subtitle.text = option_content.subtitle
	
	icon.texture =  ImageTexture.new().create_from_image(texture)
	
	option = option_content;
