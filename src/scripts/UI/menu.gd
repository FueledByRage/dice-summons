extends Control

@onready var select_arrow = $Select_arrow;

var current_option = 0;
var maximum_options = 0;

signal select;

func _input(event: InputEvent) -> void:
	if(event.is_action_released("move_right")):
		_handle_option_change(1)
	elif(event.is_action_released("move_left")):
		_handle_option_change(-1)
	elif(event.is_action_released("confirm")):
		var selected_option = $box/row.get_children()[current_option]
		select.emit(selected_option.option);
		queue_free();

func _handle_option_change(modifier):
	var row =  $box/row;
	current_option = current_option + modifier;
	
	if(current_option > maximum_options):
		current_option = 0;
	elif (current_option < 0):
		current_option = maximum_options
	
	var selected_option = row.get_children()[current_option];
	
	select_arrow.position = selected_option.position;


func init(options, on_select):
	var row =  $box/row;

	for option in options:
		var option_box = load("res://src/scenes/UI/option_box.tscn").instantiate();
		
		option_box.init(option)
		
		row.add_child(option_box);

	select.connect(on_select, 4)
	maximum_options = row.get_child_count() - 1;
