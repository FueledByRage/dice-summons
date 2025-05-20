extends Control

var MAXIMUM_ROLLS = 0

var results = []
var number_of_rolls = 0
signal roll_completed
const DISCONNECT_ONESHOT = CONNECT_ONE_SHOT

func setup(number_of_rolls):
	self.number_of_rolls = number_of_rolls

func roll(on_roll_completed):
	MAXIMUM_ROLLS = number_of_rolls
	results.clear()
	
	var dice_roll_scene = load("res://src/scenes/dice_roll.tscn")
	
	for i in range(number_of_rolls):
		var dice = dice_roll_scene.instantiate()
		$dices_wrapper/rows_container.add_child(dice)
		dice.start(on_roll)
		
		await get_tree().create_timer(.5).timeout

	roll_completed.connect(on_roll_completed, DISCONNECT_ONESHOT)

func on_roll(result):
	results.append(result)
	if results.size() == MAXIMUM_ROLLS:
		await get_tree().create_timer(.7).timeout
		roll_completed.emit(results)
		queue_free()
