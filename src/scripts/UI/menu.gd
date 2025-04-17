extends Control

@onready var row = $box/row;
@onready var select_arrow = $Select_arrow;

var current_option = 0;
var maximum_options = 0;

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("move_right")):
		_handle_option_change(1)
	elif(event.is_action_pressed("move_left")):
		_handle_option_change(-1)
	pass

func _handle_option_change(modifier):
	if((maximum_options + modifier) > maximum_options):
		current_option = 0;
	elif (maximum_options + modifier < 0):
		current_option = maximum_options
		
	select_arrow.global_position = row.get_children()[current_option].global_position;

func init(options):
	for option in options:
		var label = Label.new();
		label.text = option.label;
		row.add_child(label)
	maximum_options = row.get_child_count();
	pass
