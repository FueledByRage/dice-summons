extends Node2D

var DAMAGE = 3;
var LIFE = 15;
var CURRENT_LIFE = LIFE;
var spells = [{
	'name': 'Heal',
	'target_type': 'all',
	'life_effect': 2,
}];

func _ready() -> void:
	update_life_label();

func apply_change_on_life(change):
	CURRENT_LIFE += change;

func update_life_label():
	var label: Label = $Control/Label
	var life_percentage = float(CURRENT_LIFE) / float(LIFE)
	var life_text = str(CURRENT_LIFE) + "/" + str(LIFE)

	if life_percentage < 0.5:
		label.add_theme_color_override("font_color", Color.RED)
	elif life_percentage <= 0.75:
		label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		label.add_theme_color_override("font_color", Color(0,.6,0))

	label.text = life_text
