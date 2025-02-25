extends Node2D

@onready var enemies_units = $Enemies
@onready var allies_units = $Allies;

func get_all_units():
	var all_units = [];
	all_units.append_array(enemies_units.get_children());
	all_units.append_array(allies_units.get_children());
	return  all_units;

func add_ally(ally):
	allies_units.add_child(ally)

func add_enemy(enemy):
	enemies_units.add_child(enemy);
