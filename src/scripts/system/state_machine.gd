extends Node
class_name State_Machine

@export var current_state : State;
var states : Dictionary = {};

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child;
			child.transitioned.connect(on_child_transitioned)
		else:
			print(child);
	current_state.enter();

func _process(delta):
	if Input.is_action_just_pressed("state"):
		print(current_state.name)
	current_state.update(delta);
	pass

func _physics_process(delta):
	current_state.physics_update(delta);
	pass

func on_child_transitioned(new_state_name: String):
	var new_state = states.get(new_state_name);
	if(new_state != null and new_state != current_state):
		current_state.exit();
		new_state.enter();
		current_state = new_state;
	else:
		print("State " + new_state_name + " not found on father " + get_parent().name + " - current state " + current_state.name);

func print_current_state():
	if Input.is_action_just_pressed("state"):
		print(current_state.name)
	pass
