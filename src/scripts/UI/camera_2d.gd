extends Camera2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func close_menu():
	if(has_node("$menu")):
		$menu.queue_free()
