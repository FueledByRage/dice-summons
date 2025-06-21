extends Control

@onready var username_input : LineEdit = $CenterContainer/MarginContainer/VBoxContainer/username
@onready var password_input : LineEdit = $CenterContainer/MarginContainer/VBoxContainer/password
@onready var feedback_label : Label = $CenterContainer/MarginContainer/VBoxContainer/feedback_label
@onready var http : HTTPRequest = $HTTPRequest;
var button : Button;

func _ready() -> void:
	button = $CenterContainer/MarginContainer/VBoxContainer/Button;
	button.pressed.connect(login)
	http.request_completed.connect(_on_login)
	pass


func login():
	if !username_input.text.is_empty() and !password_input.text.is_empty():
		button.disabled = true;
		feedback_label.text = "Carregando..."
		
		var body = JSON.stringify({
			"username": username_input.text,
			"password": password_input.text
		})
		var headers = ["Content-Type: application/json"]
		
		http.request("http://localhost:4000/login", headers, HTTPClient.METHOD_POST, body)
		

func _on_login(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code != 200:
		feedback_label.text = "Username e/ou senha incorreta"
		button.disabled = false
		return

	var json_text := body.get_string_from_utf8()
	var data = JSON.parse_string(json_text)

	if typeof(data) == TYPE_DICTIONARY and data.has("user"):
		var username = data["user"].get("username", "")
		UserSession.login(username)
		get_tree().change_scene_to_file("res://src/scenes/stages/hall.tscn")
	else:
		feedback_label.text = "Erro ao processar resposta do servidor"

	
