extends Node

enum States { ATTACKING, PLACING, IDLE, SELECTING, MOVING }

var state = States.IDLE
@onready var tile_map_layer = $TileMap;

func _input(event: InputEvent) -> void:
	match state:
		States.PLACING:
			if event.is_action_pressed("place"):
				tile_map_layer.place()
				state = States.IDLE
		States.MOVING:
			if event.is_action("left_click"):
				var mouse_position = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
				if mouse_position in tile_map_layer.possible_move_cells:
					var summon = tile_map_layer.summons_map[0].node
					tile_map_layer.move_summon(summon, mouse_position)
					state = States.IDLE

		States.IDLE:
			if event.is_action_pressed("placing"):
				state = States.PLACING
				tile_map_layer.to_placing();

		States.SELECTING:
			if event.is_action_pressed("move_right"):
				if tile_map_layer.selected_target_index >= tile_map_layer.select_targets.size():
					tile_map_layer.selected_target_index = 0
				tile_map_layer.selected_target_index += 1
			elif event.is_action_pressed("move_left") and tile_map_layer.selected_target_index != 0:
				tile_map_layer.selected_target_index -= 1
			elif event.is_action_pressed("confirm"):
				on_confirm()

func on_confirm():
	var selected = tile_map_layer.select_targets[tile_map_layer.selected_target_index]
	if state == States.SELECTING:
		tile_map_layer.display_summon_options(selected.node)
		tile_map_layer.select_targets = selected.node
		state = States.ATTACKING
	elif state == States.ATTACKING:
		print("executing " + selected.name)
