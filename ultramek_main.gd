class_name UltraMekMain
extends Node

signal connect_tcp_server_main
signal request_board_signal(fname: String)

const NODE_NAME: String = "Main"
const DEFAULT_HOST: String = "127.0.0.1"
const DEFAULT_PORT: int = 8563

const MAIN_MENU_NODE_NAME: String = "MainMenu"
const TCP_NODE_NAME: String = "TCPClient"
const BOARD3D_NODE_NAME: String = "Board3D"

const BOARD3D_SCENE = preload("res://board3d.tscn")

const CONNECT_SERVER_BUTTON: String = "ConnectButton"
const NEW_GAME_BUTTON: String = "NewGameButton"

var game_client: UltraMekClient = null


var main_menu_node: Node
var connect_server_button: Node 
var new_game_button: Node
var board_node: Node

# flags
var main_menu_visible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_tcp_server_connect()
	_setup_game()

func _tcp_server_connect()->String:
	print("Alert: Main Menu Server Connect")
	#connect_tcp_server_main.emit()
	game_client = UltraMekClient.new()
	game_client.name = TCP_NODE_NAME
	var host = DEFAULT_HOST
	var port = DEFAULT_PORT
	await game_client.set_host_and_port(host,port)
	await add_child(game_client)
	return "Server Start"

func _hide_main_menu()->void:
	main_menu_node.visible = false
	main_menu_visible = false

func _show_main_menu()->void:
	main_menu_node.visible = true
	main_menu_visible = true

func _new_game_start(fname: String)->void:
	if has_node(BOARD3D_NODE_NAME):
		var board_node_temp = get_node(BOARD3D_NODE_NAME)
		remove_child(board_node_temp)
	
	var board_scene = BOARD3D_SCENE.instantiate()
	board_scene.name = BOARD3D_NODE_NAME
	add_child(board_scene)
	board_node = board_scene
	
	_hide_main_menu()
	if game_client._connect_tcp == true:
		print("Alert: Game Start")
		request_board_signal.emit(fname)
		#var fname: String = "test/samples/snow.board"
		#var answer: String = await game_client.request_board(fname)
		
		
		
func _server_process(delta: float) -> void:
	var status = await connect_server_button.connect("connect_tcp_server",_tcp_server_connect)

func _game_start_process(delta: float)->void:
	if game_client._connect_tcp == true:
		if new_game_button.disabled == true:
			new_game_button.disabled = false
		new_game_button.connect("new_game_start",_new_game_start)
	else:
		new_game_button.disabled = true

func _collect_board_data(dim_x:int,dim_y:int)->void:
	print("Alert: Board data recieved!")
	Global.game_state["board_state"] = {"dim_x":dim_x,"dim_y":dim_y,"active":true}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_server_process(delta)
	if game_client != null:
		_game_start_process(delta)
	await Global.connect("processed_board_data",_collect_board_data)
	print("Alert: Game State: ",Global.game_state)
	
func _setup_game():
	_setup_buttons()
	_set_mouse()

func _set_mouse():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Load the custom images for the mouse cursor.
	#var arrow = load("res://arrow.png")
	#var beam = load("res://beam.png")
	#Input.set_custom_mouse_cursor(arrow)
	#Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
func _setup_buttons():
	main_menu_node = find_child(MAIN_MENU_NODE_NAME,true,false)
	connect_server_button = find_child(CONNECT_SERVER_BUTTON,true,false)
	new_game_button = find_child(NEW_GAME_BUTTON,true,false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.get_keycode() == KEY_ESCAPE:
			if main_menu_visible == true:
				await _hide_main_menu()
			else:
				await _show_main_menu()
			
