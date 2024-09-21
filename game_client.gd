class_name UltraMekClient
extends Node

var HOST: String = "127.0.0.1"
var PORT: int = 8563
const RECONNECT_TIMEOUT: float = 3.0

const NONE_ANSWER: String = "Nothing!"

const RQ: String = "REQUEST_TYPE"
const MAP_RQ: String = "BOARD_REQUEST"
const FILENAME: String = 'filename'

signal recieved_board(board_json)

#const Client = preload("res://tcp_client.gd")
#var _client: Client = Client.new()
var _client: UltraMekTCPClient # = UltraMekTCPClient.new()
var board_requested: bool
var board_fname: String = ""
var _connect_tcp: bool = false
var main_node: Node = null

func set_host_and_port(host: String, port: int):
	HOST = host
	PORT = port

func _get_connect_signal():
	print("Alert: Got connect signal from main!")
	_connect_tcp = true

func _ready() -> void:
	await _init_cpp_bindings()
	_client = UltraMekTCPClient.new()
	#_client.connect("data", _print_server_data)
	add_child(_client)
	board_requested = false
	_connect_tcp = false
	main_node = get_parent()

func _process(delta: float) -> void:
	#var mm = get_parent()
	#await mm.connect("connect_tcp_server_main",_get_connect_signal)
	#print("Connected TCP? ",_connect_tcp)
	if _connect_tcp == true:
		await _process_routine(delta)
	else:
		_connect_tcp = await _client.connect_to_host(HOST, PORT)	

func request_board(fname: String) -> void:
	var answer: String = NONE_ANSWER
	#print("Sent: ", board_requested)
	if board_requested == true:
		var request: String = await _request_map_file(fname)
		var message: PackedByteArray = await request.to_utf8_buffer() 
		#print("Client data 1 : ", message.get_string_from_utf8())
		await _client.connect_to_host(HOST, PORT)
		await _handle_client_data(message)
		answer = await _client.recieve()
		var answer_dict = JSON.parse_string(answer)
		if answer_dict != null:
			var recieved_map = answer_dict[MAP_RQ] 
			print("Answer: ", recieved_map)
			recieved_board.emit(recieved_map)
			board_requested = false
	
	#return answer
func start_requesting_board(fname: String):
	board_requested = true
	board_fname = fname

func _process_routine(delta: float) -> void:
	#var fname: String = "test/samples/snow.board"
	if main_node != null:
		await main_node.connect("request_board_signal",start_requesting_board)
		await request_board(board_fname)
		
	
func _handle_client_data(data: PackedByteArray) -> bool:
	#print("Client data 2 : ", data.get_string_from_utf8())
	var message: PackedByteArray = data
	await _client.send(message)
	return true
	
func _request_map_file(filename: String) -> String:
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
