extends Node

const HOST: String = "127.0.0.1"
const PORT: int = 8563
const RECONNECT_TIMEOUT: float = 3.0

const RQ: String = "REQUEST_TYPE"
const MAP_RQ: String = "BOARD_REQUEST"
const FILENAME: String = 'filename'

const Client = preload("res://tcp_client.gd")
var _client: Client = Client.new()
var sent: bool

func _ready() -> void:
	#_client.connect("data", _print_server_data)
	add_child(_client)
	await _client.connect_to_host(HOST, PORT)
	sent = false
	
func _process(delta: float) -> void:
	var fname: String = "test/samples/snow.board"
	var answer: String = ""
	print("Sent: ", sent)
	if sent == false:
		var request: String = await request_map(fname)
		var message: PackedByteArray = await request.to_utf8_buffer() 
		print("Client data 1 : ", message.get_string_from_utf8())
		await _client.connect_to_host(HOST, PORT)
		await _handle_client_data(message)
		answer = await _client.recieve()
		var answer_dict = JSON.parse_string(answer)
		if answer_dict != null:
			print("Answer: ", answer_dict[MAP_RQ])
	
func _handle_client_data(data: PackedByteArray) -> bool:
	print("Client data 2 : ", data.get_string_from_utf8())
	var message: PackedByteArray = data
	await _client.send(message)
	return true
	
func request_map(filename: String) -> String:
		var rdict: Dictionary = {}
		rdict[MAP_RQ] = {"filename":filename}
		var output: String = JSON.stringify(rdict) + '\n'
		return output
