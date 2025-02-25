class_name UltraMekMain
extends Node

signal connect_tcp_server_main

const REQUEST_BOARD_SIGNAL: String = "request_board_signal"
signal request_board_signal(fname: String)

const REQUEST_PLAYERS_SIGNAL: String = "request_players_signal"
signal request_players_signal(forces: Dictionary)

const REQUEST_INITIATIVE_SIGNAL: String = "request_initiative_signal"
signal request_initiative_signal(data: Dictionary)

const REQUEST_SIGNAL: String = "request_signal"
signal request_signal(requet_type: String, request_data: Dictionary,req_id: int)
var request_counter: int = 0
var active_requests: Array[int] = []
var active_request_types: Array[String] = []

const DEPLOY_UNIT_SIGNAL: String = "deploy_unit_signal"
signal deploy_unit_signal(player_name: String, unit_id: String,pos: Vector3)

const PLAY_PHASE_START_SOUND_SIGNAL: String = "play_phase_start_sound_signal"
signal play_phase_start_sound_signal

const NODE_NAME: String = "Main"
const DEFAULT_HOST: String = "127.0.0.1"
const DEFAULT_PORT: int = 8563

const MAIN_MENU_NODE_NAME: String = "MainMenu"
const SOUND_NODE_NAME: String = "Sound"
const TCP_NODE_NAME: String = "TCPClient"
const BOARD3D_NODE_NAME: String = "Board3D"
const HUD_NODE_NAME: String = "HUD"
const DEPLOYMENT_HUD_SCENE: String = "res://gdsrc/hud/deployment_hud.tscn"
const INITIATIVE_HUD_SCENE: String = "res://gdsrc/hud/initiative_hud.tscn"
const MOVEMENT_HUD_SCENE: String = "res://gdsrc/hud/movement_hud.tscn"

const BOARD3D_SCENE = preload("res://gdsrc/board/board3d.tscn")

const CONNECT_SERVER_BUTTON: String = "ConnectButton"
const NEW_GAME_BUTTON: String = "NewGameButton"

const SETTING_FILE: String = "res://settings.json"
const GAME_SETTINGS_KEY: String = "game_settings"
const BOARD_KEY: String = "board"
const PLAYERS_KEY: String = "players"
const PLAYER_KEY: String = "player"
const INITIATIVE_HUD_NAME: String = "InitiativeHud"
const DEPLOYMENT_HUD_NAME: String = "DeploymentHud"
const MOVEMENT_HUD_NAME: String = "MovementHud"

var game_client: UltraMekClient = null
var settings: Dictionary = {}
var game_settings: Dictionary = {}
var initiatives: Dictionary = {}
var init_dices: Dictionary = {}

# main menu buttons
var main_menu_node: Node
var connect_server_button: Node 
var new_game_button: Node

# hud nodes
var initiative_hud_node: Node = null
var deployment_hud_node: Node = null
var movement_hud_node: Node = null

# flags
var main_menu_visible: bool = false
var current_game_phase: String
var settings_recieved: bool = false
var board_recieved: bool = false 
var players_recieved: bool = false
var answer_recieved: bool = false
var game_settings_set: bool = false
var game_set_up: bool = false
var hotseat: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_tcp_server_connect()
	await _read_settings(SETTING_FILE)
	await _setup_game()
	Global.main = self
	await _connect_signals()

func _connect_signals()->void:
	var status = await connect_server_button.connect("connect_tcp_server",_tcp_server_connect)
	await game_client.connect(UltraMekClient.RECIEVED_PLAYER_SIGNAL,_collect_player_data)
	new_game_button.connect("new_game_start",_new_game_start)
	await Global.connect("processed_board_data",_collect_board_data)
	game_client.connect(UltraMekClient.RECIEVED_INITIATIVE_SIGNAL,_set_initiatives)
	game_client.connect(UltraMekClient.DEACTIVATE_REQUEST_SIGNAL,_deactivate_request)

func _send_request(request_type: String, request_data: Dictionary)->void:
	if not request_type in active_request_types:
		request_signal.emit(request_type,request_data,request_counter)
		active_requests.append(request_counter)
		active_request_types.append(request_type)
		request_counter = (request_counter+1)%10000001
	
func _deactivate_request(req_id: int,req_type: String)->void:
	var ind: int = await active_requests.find(req_id)
	if ind >= 0:
		active_requests.remove_at(ind)
		active_request_types.remove_at(ind)
	

func _tcp_server_connect()->String:
	print("Alert: Main Menu Server Connect")
	#connect_tcp_server_main.emit()
	#game_client = UltraMekClient.new()
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
	Global.settings.set_settings(settings,game_settings)

func _hide_main_menu()->void:
	main_menu_node.visible = false
	main_menu_visible = false
	if initiative_hud_node!=null:
		add_child(initiative_hud_node)
	elif deployment_hud_node!=null:
		add_child(deployment_hud_node)

func _show_main_menu()->void:
	main_menu_node.move_to_front()
	main_menu_node.visible = true
	main_menu_visible = true
	if initiative_hud_node!=null:
		remove_child(initiative_hud_node)
	elif deployment_hud_node!=null:
		remove_child(deployment_hud_node)
	
	
	

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
		_send_request(UltraMekClient.MAP_RQ,{"filename":fname})
		_send_request(UltraMekClient.PLA_RQ,players)
		
		
func _server_process(delta: float) -> void:
	pass
	#var status = await connect_server_button.connect("connect_tcp_server",_tcp_server_connect)

func _game_start_process(delta: float)->void:
	if game_client._connect_tcp == true: 
		if new_game_button.disabled == true:
			new_game_button.disabled = false
		#new_game_button.connect("new_game_start",_new_game_start)
	else:
		new_game_button.disabled = true
		
	if Global.game_phase == Global.PREPARATION_PHASE:
		#await Global.connect("processed_board_data",_collect_board_data)
		#await game_client.connect(UltraMekClient.RECIEVED_PLAYER_SIGNAL,_collect_player_data)
		if _check_game_ready(delta) == true:
			_setup_session()
			#Global.game_phase = Global.DEPLOYMENT_PHASE
			Global.game_phase = Global.INITIATIVE_PHASE
			

func _setup_session()->void:
	Global.round_nr = 0
	Global.player_order = []
	if Global.settings.get_session_type()==SettingsManager.HOT_SEAT_SESSION:
		assert(Global.settings.get_session_player_number()>1,"Too few players for hotseat!")
		for p in Global.players.keys():
			Global.session_players.append(p)
	else:
		assert(false,"Session type unknown!")
	
	# before initiative we start with the host.
	Global.active_player = Global.players[Global.settings.get_host_player()]
	

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
		print("Added Player: ",player.get_player_id())
	players_recieved = true
	
func _set_new_game_info(board: String,forces: Dictionary, settings: Dictionary):
	Global.game_metadata[Global.BOARD_KEY] = board
	Global.game_metadata[Global.FORCES_KEY] = forces
	Global.game_metadata[Global.SETTINGS_KEY] = settings
	game_settings_set = true

func _deploy_unit(player_id: String, unit_id: String, pos: Vector3):
	deploy_unit_signal.emit(player_id, unit_id,pos)

func reset_initiative()->void:
	initiatives = {}
	Global.player_order = []
	Global.active_player = Global.players[Global.settings.get_host_player()]

func _deployment_phase_finished()->void:
	reset_initiative()
	Global.game_phase = Global.INITIATIVE_PHASE
	remove_child(deployment_hud_node)
	deployment_hud_node.queue_free()
	Global.round_nr += 1

func _deployment_process(delta: float)->void:
	if deployment_hud_node != null:
		if not deployment_hud_node.is_connected(DeploymentHud.DEPLOYMENT_UNIT_CONFIRMED_SIGNAL,_deploy_unit):
			deployment_hud_node.connect(DeploymentHud.DEPLOYMENT_UNIT_CONFIRMED_SIGNAL,_deploy_unit)
		if not deployment_hud_node.is_connected(DeploymentHud.DEPLOYMENT_FINISHED_SIGNAL,_deployment_phase_finished):
			deployment_hud_node.connect(DeploymentHud.DEPLOYMENT_FINISHED_SIGNAL,_deployment_phase_finished)
		
func _roll_initiative(player_id: String):
	var initiative_data: Dictionary = {Global.PLAYER_KEY:player_id,Global.ROUND_KEY:Global.round_nr}
	_send_request(UltraMekClient.INI_RQ,initiative_data)
	Global.sound.play_dice_sound()

func _finish_initiative_phase():
	Global.active_player = Global.players[Global.player_order[0]]
	if Global.round_nr == 0:
		Global.game_phase = Global.DEPLOYMENT_PHASE
	else:
		Global.game_phase = Global.MOVEMENT_PHASE
	

func _set_initiatives(init_data: Dictionary)->void:
	#print("Init rolled: ",init_data)
	var player_id: String = init_data[Global.PLAYER_KEY]
	var init: int = init_data[Global.INITIATIVE_ROLLED_KEY]
	var order: Array[String] = [] 
	for ini in init_data[Global.PLAYER_ORDER_KEY]:
		order.append(str(ini))
	
	if len(order)>0:
		Global.player_order = order
	initiatives[player_id] = init
	init_dices[player_id] = init_data[Global.DICES_KEY]
	
func _initiative_process()->void:
	if initiative_hud_node != null:
		if not initiative_hud_node.is_connected(InitiativeHud.INIT_BUTTON_PRESSED_SIGNAL,_roll_initiative):
			initiative_hud_node.connect(InitiativeHud.INIT_BUTTON_PRESSED_SIGNAL,_roll_initiative)
		if not initiative_hud_node.is_connected(InitiativeHud.INIT_BUTTON_PRESSED2_SIGNAL,_finish_initiative_phase):
			initiative_hud_node.connect(InitiativeHud.INIT_BUTTON_PRESSED2_SIGNAL,_finish_initiative_phase)
		if Global.active_player.get_player_id() in initiatives.keys():
			var pid: String = Global.active_player.get_player_id()
			var pname: String = Global.active_player.get_player_name()
			initiative_hud_node.show_initiative_button(pname, initiatives[pid],init_dices[pid])
			if len(initiatives)==len(Global.players) and len(Global.player_order)==0:
				initiatives={}
				initiative_hud_node.show_reroll_button()
				
	if game_client != null and not game_client.is_connected(UltraMekClient.RECIEVED_INITIATIVE_SIGNAL,_set_initiatives):
		game_client.connect(UltraMekClient.RECIEVED_INITIATIVE_SIGNAL,_set_initiatives)

func _movement_process()->void:
	if movement_hud_node != null:
		pass
	
func _update_request_process()->void:
	pass
	#game_client.connect(UltraMekClient.DEACTIVATE_REQUEST_SIGNAL,_deactivate_request)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_server_process(delta)
	if game_client != null:
		_game_start_process(delta)
		_setup_hud(delta)
		_initiative_process()
		_deployment_process(delta)
		_update_request_process()
		
		
	#print("Alert: Game State: ",Global.game_state)
	#print("Alert: Game Phase: ",Global.game_phase)
	
func _setup_game():
	game_client = UltraMekClient.new()
	_apply_game_settings()
	_setup_buttons()
	_set_mouse()
	_set_states()
	_setup_sound()

func _apply_game_settings() -> void:
	pass

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
	_setup_initiative_hud(delta)
	_setup_movement_hud(delta)

func _setup_initiative_hud(delta: float) -> void:
	if Global.game_phase == Global.INITIATIVE_PHASE and initiative_hud_node == null:
		initiative_hud_node = _instantiate_phase_hud(INITIATIVE_HUD_SCENE,INITIATIVE_HUD_NAME)
	elif Global.game_phase != Global.INITIATIVE_PHASE and initiative_hud_node != null:
		_remove_phase_hud(initiative_hud_node)
		
func _setup_deployment_hud(delta: float)->void:
	if Global.game_phase == Global.DEPLOYMENT_PHASE and deployment_hud_node == null:
		deployment_hud_node = _instantiate_phase_hud(DEPLOYMENT_HUD_SCENE,DEPLOYMENT_HUD_NAME)
	elif Global.game_phase != Global.DEPLOYMENT_PHASE and deployment_hud_node != null:
		_remove_phase_hud(deployment_hud_node)
		
func _setup_movement_hud(delta: float)->void:
	if Global.game_phase == Global.MOVEMENT_PHASE and movement_hud_node == null:
		movement_hud_node = _instantiate_phase_hud(MOVEMENT_HUD_SCENE,MOVEMENT_HUD_NAME)
	elif Global.game_phase != Global.MOVEMENT_PHASE and movement_hud_node != null:
		_remove_phase_hud(movement_hud_node)
			


func _instantiate_phase_hud(scene_file,scene_name) -> Node:
	var result: Node = null
	var hud_scene = load(scene_file)
	result = hud_scene.instantiate()
	result.set_name(scene_name)
	add_child(result)
	result.visible=true
	play_phase_start_sound_signal.emit()
	return result

func _remove_phase_hud(phase_hud_node)->void:
	remove_child(phase_hud_node)
	phase_hud_node.queue_free()

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
			
