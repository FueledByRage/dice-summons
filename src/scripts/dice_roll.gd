extends MarginContainer

signal roll_completed

func start(on_roll):
	roll_completed.connect(on_roll, CONNECT_ONE_SHOT)
	
	_roll()

func _roll():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var result = rng.randi_range(1, 6)
	
	roll_completed.emit(result)
	
	if has_node("result"):
		$result.text = str(result)
	
	return result
