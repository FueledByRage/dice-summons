extends Node

var username: String = ""
var is_logged_in: bool = false

func login(name: String):
	username = name
	is_logged_in = true

func logout():
	username = ""
	is_logged_in = false
