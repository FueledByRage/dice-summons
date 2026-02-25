extends Node

var username: String = ""
var token : String
var is_logged_in: bool = false

func login(data: Dictionary):
	username = data.get("username", "?")
	token = data.get("session", "?")
	is_logged_in = true

func logout():
	username = ""
	is_logged_in = false
