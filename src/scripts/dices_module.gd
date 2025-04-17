extends Node


@onready var dices_collection = $dices_collection;
@onready var dices = [];

func _ready() -> void:
	dices = dices_collection.get_player_collection();
	dices.shuffle();

func draw_dices(number_to_draw):
	dices.slice(0, number_to_draw);

func put_dices(dices_to_append):
	dices.append_array(dices_to_append);
