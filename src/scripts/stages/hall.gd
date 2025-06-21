extends Node

var socket := WebSocketPeer.new()
@onready var username_input : LineEdit = $CenterContainer/VBoxContainer/username
@onready var send_button : Button;

func _ready():
	send_button = $CenterContainer/VBoxContainer/send
	
	send_button.pressed.connect(send_invite)
	
	var err = socket.connect_to_url("ws://localhost:4000/ws")
	if err != OK:
		print("Erro ao conectar WebSocket: ", err)
	else:
		print("Conectando ao servidor...")
	set_process(true)

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count() > 0:
				var raw_msg = socket.get_packet().get_string_from_utf8()
				var json_result = JSON.parse_string(raw_msg)

				if typeof(json_result) == TYPE_DICTIONARY:
					handle_message(json_result)
				else:
					print("Mensagem inválida recebida: ", raw_msg)

		WebSocketPeer.STATE_CLOSING:
			pass

		WebSocketPeer.STATE_CLOSED:
			print("WebSocket desconectado: ", socket.get_close_reason())
			set_process(false)

func handle_message(msg: Dictionary) -> void:
	var pop_up = load("res://src/scenes/UI/pop_up.tscn")
	match msg.get("type", ""):
		"invite":
			var options = [{
				"message": "Você recebeu uma nova mensagem",
				"options": [
					{
						"text": "Okay",
						"action": func() : print("okay")
					},
					{
						"text": "Decline",
						"action": func() : print("not okay")
					}
				]
			}]
			
			var from_user = msg.get("from")
			pop_up.init(options)
			
			add_child(pop_up)
		"invite_response":
			print("📩 Resposta de ", msg.get("from"), ": ", msg.get("status"))
		_:
			print("❓ Mensagem desconhecida: ", msg)

func send_invite():
	send_button.disabled = true
	
	if !username_input.text.is_empty():
		var msg := {
			"type": "invite",
			"from":  UserSession.username,
			"to": username_input.text
		}
		socket.send_text(JSON.stringify(msg))
	
	send_button.disabled = false;

func send_invite_response(from_user: String, accepted: bool):
	var msg := {
		"type": "invite_response",
		"from": from_user,
		"response": accepted
	}
	socket.send_text(JSON.stringify(msg))
