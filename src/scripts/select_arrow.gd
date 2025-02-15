extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_idle_animation();

func init_idle_animation():
	var tween = get_tree().create_tween();
	var target_position = global_position - Vector2(0, -10);
	tween.tween_property(self, 'position', target_position, 3);
