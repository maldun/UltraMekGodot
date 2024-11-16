class_name UltraMekClient
extends Node

var HOST: String = "127.0.0.1"
var PORT: int = 8563
const RECONNECT_TIMEOUT: float = 3.0
const DELAY_TIMEOUT: float = 0.3

const NONE_ANSWER: String = "Nothing!"

const RQ: String = "REQUEST_TYPE"
const MAP_RQ: String = "BOARD_REQUEST"
const PLA_RQ: String = "PLAYER_REQUEST"
const ACT_RQ: String = "ACTION_REQUEST"
const STA_RQ: String = "STATUS_REQUEST"
const INI_RQ: String = "INITIATIVE_REQUEST"
const FILENAME: String = 'filename'

# signals
const RECIEVED_BOARD_SIGNAL = "recieved_board"
signal recieved_board(board_json)

const RECIEVED_PLAYER_SIGNAL = "recieved_player_data"
signal recieved_player_data(deployment_json)

const RECIEVED_ACTION_SIGNAL: String = "recieved_action_data"
signal recieved_action_data(action_json: Dictionary)

const RECIEVED_INITIATIVE_SIGNAL: String = "recieved_initiative_data"
signal recieved_initiative_data(initiative_json: Dictionary)

const ANSWER_RECIEVED_SIGNAL: String = "answer_recieved_signal"
signal answer_recieved_signal(request_type: String, data: Dictionary)

const SIGNAL_MAP: Dictionary = {PLA_RQ:RECIEVED_PLAYER_SIGNAL,
								INI_RQ:RECIEVED_INITIATIVE_SIGNAL,
								MAP_RQ:RECIEVED_BOARD_SIGNAL,
								}

const DEACTIVATE_REQUEST_SIGNAL: String = "deactivate_request_signal"
signal deactivate_request_signal(req_id: int)

var _client: UltraMekTCPClient # = UltraMekTCPClient.new()

var board_requested = false
var requested: bool = false
var current_request: int = -1
var request_stack: Array[String] = []
var request_data_stack: Array = []
var active_ids: Array[int] = []
var processed_data_stack: Array = []

var board_fname: String = ""
var players: Dictionary = {}
var actions: Dictionary = {}
var initiative: Dictionary = {}
var _connect_tcp: bool = false
var main_node: Node = null

func set_host_and_port(host: String, port: int):
	HOST = host
	PORT = port

func _get_connect_signal():
	#print("Alert: Got connect signal from main!")
	_connect_tcp = true

func _ready() -> void:
	await _init_cpp_bindings()
	_client = UltraMekTCPClient.new()
	#_client.connect("data", _print_server_data)
	add_child(_client)
	_connect_tcp = false
	main_node = get_parent()
	main_node.connect(UltraMekMain.REQUEST_SIGNAL,start_requesting)

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
	if board_requested == true and fname != '':
		var request: String = await _request_map_file(fname)
		var message: PackedByteArray = await request.to_utf8_buffer() 
		#print("Client data 1 : ", message.get_string_from_utf8())
		await _client.connect_to_host(HOST, PORT)
		await _handle_client_data(message)
		answer = await _client.recieve()
		var answer_dict = JSON.parse_string(answer)
		if answer_dict != null:
			var recieved_map = answer_dict[MAP_RQ] 
			#print("Answer: ", recieved_map)
			recieved_board.emit(recieved_map)
			board_requested = false
			board_fname = ''
	
	#return answer

func _requesting(request_dic: Dictionary, request_type:String):
	var answer: String = NONE_ANSWER
	#if true == true:
	if len(main_node.active_requests)>0:
		var request: String = await _request_dict(request_dic,request_type)
		#print("Sent: ", request)
		var message: PackedByteArray = await request.to_utf8_buffer()
		await _client.connect_to_host(HOST, PORT)
		await _handle_client_data(message)
		answer = await _client.recieve()
		var answer_dict = JSON.parse_string(answer)
		return answer_dict
	
func start_requesting_board(fname: String):
	board_requested = true
	board_fname = fname
	#print("Sent board 1: ", board_requested, board_fname)
	
func start_requesting(request_type_key: String, request_data_dict: Dictionary, req_id: int):
	requested = true
	#request_type = request_type_key
	#request_data = request_data_dict
	if not req_id in active_ids:
		request_stack.append(request_type_key)
		request_data_stack.append(request_data_dict)
		active_ids.append(req_id)
		current_request = req_id
		

func requesting()->void:
	if len(request_stack)>0 and len(request_data_stack)>0:
		var RQ_type = request_stack[0]
		var requested_data = request_data_stack[0]
		var req_id: int = active_ids[0]
		var answer_dict = await _requesting(requested_data,RQ_type)
		#print("Requested2: ",RQ_type, answer_dict if answer_dict == null else len(answer_dict))
		if answer_dict != null:
			if RQ_type in answer_dict.keys():
				var recieved_result = answer_dict[RQ_type]
				print("Answer: ",recieved_result)
				processed_data_stack.append(recieved_result)
				emit_signal(SIGNAL_MAP[RQ_type],recieved_result)
				requested=false
				request_data_stack.pop_front()
				request_stack.pop_front()
				active_ids.pop_front()
				deactivate_request_signal.emit(req_id)
				current_request = -1
			
func _cleanup_active_requests()->void:
	var new_active_ids: Array[int] = []
	var new_request_stack: Array[String] = []
	var new_request_data_stack: Array = []
	for counter in range(len(active_ids)):
		var id: int = active_ids[counter]
		if id in main_node.active_requests:
			new_active_ids.append(id)
			new_request_stack.append(request_stack[counter])
			new_request_data_stack.append(request_data_stack[counter])
	active_ids = new_active_ids
	request_stack = new_request_stack
	request_data_stack = new_request_data_stack

func _process_routine(delta: float) -> void:
	#var fname: String = "test/samples/snow.board"
	if main_node != null:
		#await main_node.connect(UltraMekMain.REQUEST_SIGNAL,start_requesting)
		
		if len(main_node.active_requests) < len(active_ids):
			await _cleanup_active_requests()
		#print("Stack: ",request_stack,main_node.active_requests,)#processed_data_stack)
			
		if (len(main_node.active_requests) > 0 and len(request_stack) > 0 and 
			len(request_data_stack)>0 and (current_request in main_node.active_requests or current_request == -1)):
			
			if current_request != active_ids[0]:
				current_request = active_ids[0]
			else:
				# keeps requesting in check
				await get_tree().create_timer(DELAY_TIMEOUT).timeout
				await requesting()
			
func _handle_client_data(data: PackedByteArray) -> bool:
	var message: PackedByteArray = data
	var result = await _client.send(message)
	return true
	
func _request_map_file(filename: String) -> String:
		var rdict: Dictionary = {}
		rdict[MAP_RQ] = {"filename":filename}
		var output: String = JSON.stringify(rdict) + '\n'
		return output
		
func _request_dict(req: Dictionary,request_type: String)-> String:
	var rdict: Dictionary = {}
	rdict[request_type] = req #players
	var output: String = JSON.stringify(rdict) + '\n'
	return output
	

func _init_cpp_bindings() -> void:
	var s = UltraMekGD.new()
	s.set_unit_length(2.0)
	print("Sumx2: ", s.doubling(60))
	print("Unit Length: ", s.get_unit_length())
	var centers = s.create_grid_centers(16,17)
	#print("Centers: ",centers)
