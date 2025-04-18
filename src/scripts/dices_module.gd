extends Node


@onready var dices_collection = $dices_collection;
@onready var dices = [];

func _ready() -> void:
	dices = dices_collection.get_player_collection();
	dices.shuffle();

func draw_dice():
	return dices.pop_front();

func put_dices(dices_to_append):
	dices.append_array(dices_to_append);
	dices.shuffle();

func draw_dices(count: int):
	var result = []

	for i in count:
		if dices.is_empty():
			break
		result.append(draw_dice())

	return result
