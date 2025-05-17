extends Node2D

@onready var enemies_units = $Enemies
@onready var allies_units = $Allies;

func get_all_units():
	var all_units = [];
	all_units.append_array(enemies_units.get_children());
	all_units.append_array(allies_units.get_children());
	return  all_units;

func add_ally(ally, target_position):
	ally.global_position = allies_units.to_local(target_position);
	allies_units.add_child(ally)

func add_enemy(enemy):
	enemies_units.add_child(enemy);
	
func update_unit():
	pass;

func get_enemies():
	return enemies_units.get_children();

func get_allies():
	return allies_units.get_children();

func has_units():
	return allies_units.get_child_count() > 0;
