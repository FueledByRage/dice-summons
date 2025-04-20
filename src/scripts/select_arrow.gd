extends Node2D

func _ready() -> void:
	#init_idle_animation();
	pass

func init_idle_animation():
	var tween = get_tree().create_tween();
	var target_position = position - Vector2(0, -10);
	tween.tween_property(self, 'position', target_position, 2);

func move_to(position):
	global_position = position;

func _on_visibility_changed() -> void:
	pass # Replace with function body.
