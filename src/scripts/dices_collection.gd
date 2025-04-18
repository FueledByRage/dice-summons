extends Node
 
var player_collection_path = "res://data/player/collection.json"

@onready var collection = ReadData.load_json_file(player_collection_path);

func _ready() -> void:
	pass

func get_player_collection():
	if collection:
		return collection;
	return [];
