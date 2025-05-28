extends Node

@onready var points_types = get_parent().Points;

@onready var points = {
	points_types.SUMMON_POINTS: {
		"value": 0,
		"maximum": 6
	},
	points_types.MOVE_POINTS: {
		"value": 0,
		"maximum": 10
	},
	points_types.ENERGY_POINTS: {
		"value": 0,
		"maximum": 5
	}
}

func get_all_points():
	return points;

func get_points(point_type) -> int:
	return points[point_type]["value"]

func get_max_points(point_type) -> int:
	return points[point_type]["maximum"]

func add_points(point_type, amount: int) -> void:
	points[point_type]["value"] = min(
		points[point_type]["value"] + amount,
		points[point_type]["maximum"]
	)

func remove_points(point_type, amount: int) -> void:
	points[point_type]["value"] = max(
		points[point_type]["value"] - amount,
		0
	)

func set_points(point_type, amount: int) -> void:
	points[point_type]["value"] = clamp(
		amount,
		0,
		points[point_type]["maximum"]
	)

func add_all_points(summon: int, move: int, energy: int) -> void:
	add_points(points_types.SUMMON_POINTS, summon)
	add_points(points_types.MOVE_POINTS, move)
	add_points(points_types.ENERGY_POINTS, energy)
