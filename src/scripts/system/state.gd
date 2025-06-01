extends Node

class_name State

@onready var stage : Table = get_parent()

signal finished(next_state, data)

func handle_input(_event):
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass

func enter():
	pass

func exit():
	pass
