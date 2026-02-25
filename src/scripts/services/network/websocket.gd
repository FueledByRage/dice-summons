extends Node
class_name WebSocket

var url: String
var headers := PackedStringArray()
var websocket := WebSocketPeer.new()
var connection_status: int

signal message_received(data)
signal connected
signal connection_error
signal disconnected

func config(config_options: Dictionary) -> WebSocket:
	url = config_options.get("url", "")
	
	var headers_dict = config_options.get("headers", {})
	for key in headers_dict.keys():
		headers.append(key + ": " + str(headers_dict[key]))
		
	websocket.handshake_headers = headers
	connection_status = websocket.connect_to_url(url)
	return self

func _ready():
	# Conectar os sinais internos do WebSocketPeer aos métodos da classe
	set_process(true)

func listen(signals = []):
	# Conectar sinais personalizados se fornecidos
	for item in signals:
		if item.has("event") and item.has("callable"):
			connect(item["event"], item["callable"])
	
	if connection_status != OK:
		push_error("Erro ao conectar ao WebSocket: %s" % connection_status)
		return

func emit_event(data: String):
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		websocket.send_text(data)
	else:
		push_error("WebSocket não está conectado")

func _process(_delta):
	websocket.poll()
	
	var state = websocket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass # Ainda conectando
		WebSocketPeer.STATE_OPEN:
			while websocket.get_available_packet_count() > 0:
				var packet = websocket.get_packet().get_string_from_utf8()
				emit_signal("message_received", packet)
		WebSocketPeer.STATE_CLOSING:
			pass # Fechando conexão
		WebSocketPeer.STATE_CLOSED:
			var code = websocket.get_close_code()
			var reason = websocket.get_close_reason()
			print("WebSocket fechado com código: %d, razão: %s" % [code, reason])
			emit_signal("disconnected")
			set_process(false)

func _on_connected(_proto = ""):
	print("WebSocket conectado")
	emit_signal("connected")

func _on_connection_error():
	print("Erro de conexão WebSocket")
	emit_signal("connection_error")

func _on_disconnected(_clean = true):
	print("WebSocket desconectado")
	emit_signal("disconnected")

func _on_data_received():
	while websocket.get_available_packet_count() > 0:
		var packet = websocket.get_packet().get_string_from_utf8()
		emit_signal("message_received", packet)

# Método para fechar a conexão
func close(code: int = 1000, reason: String = ""):
	websocket.close(code, reason)

# Método para verificar o status da conexão
func is_connection_open() -> bool:
	return websocket.get_ready_state() == WebSocketPeer.STATE_OPEN

# Método para enviar dados (alias para emit_event)
func send(data: String):
	emit_event(data)
