extends Node2D

func init_dice(dice_map):
	var summon_scene = preload("res://src/scenes/summon.tscn");
	
	var summon_instance = summon_scene.instantiate();
	
	summon_instance.global_position = $spawner.global_position;
	
	add_child(summon_instance);
	
	$tile.init_tile(dice_map);
	pass
