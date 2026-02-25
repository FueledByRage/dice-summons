extends Node

@onready var username_input: LineEdit = $VBoxContainer/CenterContainer/VBoxContainer/username
@onready var send_button: Button = $VBoxContainer/CenterContainer/VBoxContainer/send
var websocket: WebSocket
var user_label: Label

func _ready():
	websocket = WebSocket.new()
	add_child(websocket)
	
	var username = UserSession.username
	send_button.pressed.connect(send_invite)
	
	user_label = $VBoxContainer/MarginContainer/HBoxContainer/user_label
	user_label.text = 'User ' + ' ' + UserSession.username
	
	var ws_url = "ws://localhost:4000/ws?username=%s" % username
	websocket.config({
		"url": ws_url,
		"headers": {
			"Authorization": UserSession.token
		}
	})
	
	websocket.connected.connect(_on_websocket_connected)
	websocket.message_received.connect(_on_message_received)
	websocket.connection_error.connect(_on_websocket_error)
	websocket.disconnected.connect(_on_websocket_disconnected)
	
	websocket.listen()

func _on_websocket_connected():
	print("✅ WebSocket conectado com sucesso!")

func _on_websocket_error():
	print("❌ Erro na conexão WebSocket")

func _on_websocket_disconnected():
	print("🔌 WebSocket desconectado")

func _on_message_received(data: String):
	print("📨 RECEBIDO:", data)
	var json_result = JSON.parse_string(data)
	if typeof(json_result) == TYPE_DICTIONARY:
		handle_message(json_result)
	else:
		print("Mensagem inválida recebida: ", data)

func handle_message(msg: Dictionary) -> void:
	var pop_up = load("res://src/scenes/UI/pop_up.tscn").instantiate()
	
	match msg.get("type", ""):
		"invite":
			var from_user = msg.get("from")
			var config = {
				"message": "Você recebeu um convite para jogar de %s" % from_user,
				"options": [
					{
						"text": "Okay",
						"action": func(): send_invite_response(from_user, true)
					},
					{
						"text": "Decline", 
						"action": func(): send_invite_response(from_user, false)
					}
				]
			}
			
			pop_up.init(config)
			add_child(pop_up)
			
		"invite_response":
			print("📩 Resposta de ", msg.get("from"), ": ", msg.get("response"))
			
		"start_match":
			get_tree().change_scene_to_file("res://src/scenes/table.tscn")
			
		_:
			print("❓ Mensagem desconhecida: ", msg)

func send_invite():
	send_button.disabled = true
	
	if !username_input.text.is_empty():
		var msg := {
			"type": "invite",
			"from": UserSession.username,
			"to": username_input.text
		}
		websocket.send(JSON.stringify(msg))
	
	send_button.disabled = false

func send_invite_response(from_user: String, accepted: bool):
	var msg := {
		"type": "invite_response",
		"from": UserSession.username,
		"to": from_user,
		"response": accepted
	}
	websocket.send(JSON.stringify(msg))
