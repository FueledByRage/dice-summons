extends Node

@onready var data = load("res://src/scripts/services/data.gd")
var player_collection_path = "res://data/player/collection.json"

var collection;

func _init() -> void:
	collection = data.load_json_file(player_collection_path);

func get_player_collection():
	if collection:
		return collection;
	return [];
