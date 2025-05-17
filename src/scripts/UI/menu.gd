extends Control

var select_arrow
var current_option = 0
var maximum_options = 0
signal select
var input_active = false

func _ready():
	select_arrow = $Select_arrow
	
	if $box/row.get_child_count() > 0:
		select_arrow.position = $box/row.get_children()[0].position
	
	set_process_input(false)
	await get_tree().create_timer(0.2).timeout
	input_active = true
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not input_active:
		return
		
	if event.is_action_released("move_right"):
		handle_option_change(1)
	elif event.is_action_released("move_left"):
		handle_option_change(-1)
	elif event.is_action_released("confirm"):
		input_active = false
		set_process_input(false)
		
		var selected_option = $box/row.get_children()[current_option]
		selected_option.action.call()
		queue_free()

func handle_option_change(modifier):
	var row = $box/row
	current_option = current_option + modifier
	
	if current_option > maximum_options:
		current_option = 0
	elif current_option < 0:
		current_option = maximum_options
	
	var selected_option = row.get_children()[current_option]
	
	select_arrow.position = selected_option.position

func init(options):
	var row = $box/row
	for option in options:
		if(option["selectable"]):
			var option_box = load("res://src/scenes/UI/option_box.tscn").instantiate()
			
			option_box.init(option)
			
			row.add_child(option_box)
	
	
	maximum_options = row.get_child_count() - 1
