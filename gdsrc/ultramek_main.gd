class_name UltraMekMain
extends Node

signal connect_tcp_server_main
signal request_board_signal(fname: String)
signal request_players_signal(forces: Dictionary)

signal deploy_unit_signal(player_name: String, unit_id: String,pos: Vector3)
const DEPLOY_UNIT_SIGNAL: String = "deploy_unit_signal"

signal play_phase_start_sound_signal
const PLAY_PHASE_START_SOUND_SIGNAL: String = "play_phase_start_sound_signal"

const NODE_NAME: String = "Main"
const DEFAULT_HOST: String = "127.0.0.1"
const DEFAULT_PORT: int = 8563

const MAIN_MENU_NODE_NAME: String = "MainMenu"
const SOUND_NODE_NAME: String = "Sound"
const TCP_NODE_NAME: String = "TCPClient"
const BOARD3D_NODE_NAME: String = "Board3D"
const HUD_NODE_NAME: String = "HUD"
const DEPLOYMENT_HUD_SCENE: String = "res://gdsrc/hud/deployment_hud.tscn"

const BOARD3D_SCENE = preload("res://gdsrc/board/board3d.tscn")

const CONNECT_SERVER_BUTTON: String = "ConnectButton"
const NEW_GAME_BUTTON: String = "NewGameButton"

const SETTING_FILE: String = "res://settings.json"
const GAME_SETTINGS_KEY: String = "game_settings"
const BOARD_KEY: String = "board"
const PLAYER_KEY: String = "players"
const DEPLOYMENT_HUD_NAME: String = "DeploymentHud"

var game_client: UltraMekClient = null
var settings: Dictionary = {}
var game_settings: Dictionary = {}

# main menu buttons
var main_menu_node: Node
var connect_server_button: Node 
var new_game_button: Node

var deployment_hud_node: Node

# flags
var main_menu_visible: bool = false
var current_game_phase: String
var settings_recieved: bool = false
var board_recieved: bool = false 
var players_recieved: bool = false
var game_settings_set: bool = false
var game_set_up: bool = false
var roll_result_recieved: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_tcp_server_connect()
	await _read_settings(SETTING_FILE)
	await _setup_game()
	Global.main = self

func _tcp_server_connect()->String:
	print("Alert: Main Menu Server Connect")
	#connect_tcp_server_main.emit()
	game_client = UltraMekClient.new()
	game_client.name = TCP_NODE_NAME
	var host = DEFAULT_HOST
	var port = DEFAULT_PORT
	await game_client.set_host_and_port(host,port)
	await add_child(game_client)
	Global.game_client = game_client
	return "Server Start"

func _read_settings(filename: String)->void:
	settings = DataHandler.get_json_data(filename)
	game_settings = DataHandler.get_json_data(settings[GAME_SETTINGS_KEY])

func _hide_main_menu()->void:
	main_menu_node.visible = false
	main_menu_visible = false

func _show_main_menu()->void:
	main_menu_node.visible = true
	main_menu_visible = true

func _new_game_start(fname: String,players: Dictionary,settings: Dictionary)->void:
	_set_states()
	_set_new_game_info(fname,players,settings)
	
	if has_node(BOARD3D_NODE_NAME):
		var board_node_temp = get_node(BOARD3D_NODE_NAME)
		remove_child(board_node_temp)
	
	var board_scene = BOARD3D_SCENE.instantiate()
	board_scene.name = BOARD3D_NODE_NAME
	add_child(board_scene)
	Global.board = board_scene
	
	_hide_main_menu()
	if game_client._connect_tcp == true:
		print("Alert: Game Start")
		request_board_signal.emit(fname)
		request_players_signal.emit(players)
		
		
func _server_process(delta: float) -> void:
	var status = await connect_server_button.connect("connect_tcp_server",_tcp_server_connect)

func _game_start_process(delta: float)->void:
	if game_client._connect_tcp == true: 
		if new_game_button.disabled == true:
			new_game_button.disabled = false
		new_game_button.connect("new_game_start",_new_game_start)
	else:
		new_game_button.disabled = true
		
	if Global.game_phase == Global.PREPARATION_PHASE:
		await Global.connect("processed_board_data",_collect_board_data)
		game_client.connect("recieved_player_data",_collect_player_data)
		if _check_game_ready(delta) == true:
			Global.round_nr = 0
			Global.game_phase = Global.DEPLOYMENT_PHASE
			#Global.game_phase = Global.INITIATIVE_PHASE

func _collect_board_data(dim_x:int,dim_y:int)->void:
	print("Alert: Board data recieved!")
	board_recieved = true
	Global.game_state["board_state"] = {"dim_x":dim_x,"dim_y":dim_y,"active":true}
	
func _check_game_ready(delta: float)->bool:
	if board_recieved==true and players_recieved==true and game_settings_set:
		return true
	else:
		return false


func _collect_player_data(player_data: Dictionary)->void:
	for name in player_data.keys():
		var player: Player = Player.new()
		player.setup_player(name,player_data[name])
		Global.players[name] = player
		print("Added Player: ",player.get_player_name())
	players_recieved = true
	Global.active_player = Global.players["player1"]
	
func _set_new_game_info(board: String,forces: Dictionary, settings: Dictionary):
	Global.game_metadata[Global._BOARD_KEY] = board
	Global.game_metadata[Global._FORCES_KEY] = forces
	Global.game_metadata[Global._SETTINGS_KEY] = settings
	game_settings_set = true

func _deploy_unit(player_name: String, unit_id: String, pos: Vector3):
	deploy_unit_signal.emit(player_name, unit_id,pos)

func _deployment_process(delta: float)->void:
	if deployment_hud_node != null:
		deployment_hud_node.connect(DeploymentHud.DEPLOYMENT_UNIT_CONFIRMED_SIGNAL,
		_deploy_unit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_server_process(delta)
	if game_client != null:
		_game_start_process(delta)
		_setup_hud(delta)
		_deployment_process(delta)
		
		
	print("Alert: Game State: ",Global.game_state)
	print("Alert: Game Phase: ",Global.game_phase)
	
func _setup_game():
	_setup_buttons()
	_set_mouse()
	_set_states()
	_setup_sound()
	
func _setup_sound():
	Global.sound = UltraMekSound.new()
	Global.sound.set_name(SOUND_NODE_NAME)
	add_child(Global.sound)

func _set_states() -> void:
	Global.game_phase = Global.PREPARATION_PHASE
	current_game_phase = Global.game_phase
	Global.round_nr = -1
	board_recieved = false
	players_recieved = false

func _set_mouse():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Load the custom images for the mouse cursor.
	#var arrow = load("res://arrow.png")
	#var beam = load("res://beam.png")
	#Input.set_custom_mouse_cursor(arrow)
	#Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
	
func _setup_hud(delta: float) -> void:
	_setup_deployment_hud(delta)


func _setup_deployment_hud(delta: float)->void:
	if Global.game_phase == Global.DEPLOYMENT_PHASE and deployment_hud_node == null:
		var deployment_scene = preload(DEPLOYMENT_HUD_SCENE)
		deployment_hud_node = deployment_scene.instantiate()
		deployment_hud_node.set_name(DEPLOYMENT_HUD_NAME)
		self.add_child(deployment_hud_node)
		deployment_hud_node.visible = true
		play_phase_start_sound_signal.emit()
	elif Global.game_phase != Global.DEPLOYMENT_PHASE and deployment_hud_node != null:
		remove_child(deployment_hud_node)
		deployment_hud_node.queue_free()

	
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
			
