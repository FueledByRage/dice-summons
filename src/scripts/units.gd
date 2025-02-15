extends Node2D

var enemies_units = [];
var allies_units = [];

func get_all_units():
	var all_units = [];
	all_units.append_array(enemies_units);
	all_units.append_array(allies_units);
	return  all_units;
