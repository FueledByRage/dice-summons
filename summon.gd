extends Node2D

var NAME = '';
var DAMAGE = 0;
var LIFE = 0;
var CURRENT_LIFE = 0;
var SPELLS = [];

var position_on_table

func init(summon_data) -> void:
	NAME = summon_data.name;
	DAMAGE = summon_data.damage;
	LIFE = summon_data.life;
	CURRENT_LIFE = summon_data.life;
	SPELLS = summon_data.spells;

func _ready() -> void:
	update_life_label();

func apply_change_on_life(change):
	CURRENT_LIFE += change;
	update_life_label();

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

func set_position_on_table(position):
	position_on_table = position;
