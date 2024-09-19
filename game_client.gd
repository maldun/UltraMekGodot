extends Node

const HOST: String = "127.0.0.1"
const PORT: int = 8563
const RECONNECT_TIMEOUT: float = 3.0

const RQ: String = "REQUEST_TYPE"
const MAP_RQ: String = "BOARD_REQUEST"
const FILENAME: String = 'filename'

signal recieved_board(board_json)

#const Client = preload("res://tcp_client.gd")
#var _client: Client = Client.new()
var _client: UltraMekTCPClient # = UltraMekTCPClient.new()
var sent: bool
var _connect_tcp: bool = false

func _get_connect_signal():
	print("Alert: Got connect signal from main!")
	_connect_tcp = true

func _ready() -> void:
	await _init_cpp_bindings()
	_client = UltraMekTCPClient.new()
	#_client.connect("data", _print_server_data)
	add_child(_client)
	await _client.connect_to_host(HOST, PORT)
	sent = false
	_connect_tcp = false

func _process(delta: float) -> void:
	var mm = get_parent()
	await mm.connect("connect_tcp_server_main",_get_connect_signal)
	if _connect_tcp == true:
		var answer: String = await _process_routine(delta)
		print("Post Answer: ", answer)
	
func _process_routine(delta: float) -> String:
	var fname: String = "test/samples/snow.board"
	var answer: String = "Nothing!"
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
			var recieved_map = answer_dict[MAP_RQ] 
			print("Answer: ", recieved_map)
			recieved_board.emit(recieved_map)
	
	return answer
	
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

func _init_cpp_bindings() -> void:
	var s = UltraMekGD.new()
	s.set_unit_length(2.0)
	print("Sumx2: ", s.doubling(60))
	print("Unit Length: ", s.get_unit_length())
	var centers = s.create_grid_centers(16,17)
	print("Centers: ",centers)
