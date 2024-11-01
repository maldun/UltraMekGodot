class_name DeploymentHud
extends Control

const DEPLOYMENT_HUD_NODE: String = "DeploymentHud"
const DEPLOYMENT_BUTTON_NODE: String = "DeploymentButtons"
const DEPLOYMENT_LOGO: String = "res://assets/menu/deploy.png"
const DEPLOYMENT_CONFIRM_BUTTON_NAME: String = "confirm_button"
const CURR_PLAYER_KEY: String = "curr_player"
const CURR_UNIT_KEY: String = "curr_unit"


var preparation_hud: Node
var deployment_buttons: Node
var logo: Button = null

var current_phase: String
var deployment_buttons_dict: Dictionary
var active_deployment_buttons: Array = []
var current_unit = {}

var main_node: Node = null

const DEPLOYMENT_BUTTON_PRESSED_SIGNAL = "deployment_button_pressed"
signal deployment_button_pressed(player_name: String, button_id: String)

const DEPLOYMENT_UNIT_CONFIRMED_SIGNAL = "deploy_unit_confirmed"
signal deploy_unit_confirmed(player_name: String,unit_id: String)

func _ready_up_node(name: String) -> Node:
	var node: Node = find_child(name,true,false)
	if node != null:
		node.visible = true
	return node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	deployment_buttons = _ready_up_node(DEPLOYMENT_BUTTON_NODE)
	current_phase = Global.game_phase
	deployment_buttons_dict = {}
	await _make_hud_visible(deployment_buttons,"Deployment Hud visible!")
	await _setup_deployment_hud()
		
func _make_hud_invisible(hud_node:Node,msg: String="invisible") -> void:
	if hud_node != null:
		hud_node.visible = false
		if msg != "":
			print('Hud Event: ',msg)
		
func _make_hud_visible(hud_node:Node,msg: String="visible") -> void:
	if hud_node != null:
		hud_node.visible = true
		if msg != "":
			print('Hud Event: ',msg)

func _load_texture_from_extern(fname: String)-> ImageTexture:
	var image = Image.load_from_file(fname)
	var texture = ImageTexture.create_from_image(image)
	return texture

func to_grey_scale(image_fname: String)->ImageTexture:
	#var image: Image = Image.new()
	var image = Image.load_from_file(image_fname)
	#image.lock()
	for i in image.get_size().x:
		for j in image.get_size().y:
			var current_pixel = image.get_pixel(i,j)
			if current_pixel.a == 1:
				current_pixel = current_pixel.darkened(0.5)#current_pixel.gray()
				#var new_color = Color.from_hsv(0,0,current_pixel)
				var new_color = Color(current_pixel,0.5)
				image.set_pixel(i,j,new_color)
	#image.unlock()
	
	var new_texture = ImageTexture.create_from_image(image)
	return new_texture
	
func color_up(image_fname: String,player_color: Color)->ImageTexture:
	#var image: Image = Image.new()
	var image = Image.load_from_file(image_fname)
	#image.lock()
	for i in image.get_size().x:
		for j in image.get_size().y:
			var current_pixel = image.get_pixel(i,j)
			if current_pixel.a == 1:
				current_pixel = current_pixel.darkened(0.5)#current_pixel.gray()
				#var new_color = Color.from_hsv(0,0,current_pixel)
				#var new_color = Color(current_pixel,0.5)
				var new_color = current_pixel.blend(player_color)
				image.set_pixel(i,j,new_color)
	#image.unlock()
	
	var new_texture = ImageTexture.create_from_image(image)
	return new_texture

func _setup_deployment_hud()->void:
	logo = Button.new()
	logo.icon = (load(DEPLOYMENT_LOGO))
	logo.set_name(DEPLOYMENT_CONFIRM_BUTTON_NAME)
	logo.disabled = true
	deployment_buttons.add_child(logo)
	
	if len(Global.players)>0:
		for player_id in Global.players.keys():
			deployment_buttons_dict[player_id] = {}
			var player_picture_data: Dictionary = Global.players[player_id].get_player_forces_images()
			for entity_key in player_picture_data.keys():
				var entity: Dictionary = player_picture_data[entity_key]
				#var entity: Dictionary = player_picture_data["1"]
				print("Player Picture Data: ",entity["gfx_2d_image"])
				var button: Button = _setup_entity_button(entity)
				deployment_buttons_dict[player_id][entity_key]=button
				
		
func _setup_entity_button(entity: Dictionary)->Button:
	var entity_button: Button = Button.new()
	var picture: String = entity["gfx_2d_image"]
	#var texture = load("res://" + picture)
	var player_color: Color = Color(0.5,0,0,0.5)
	var texture = color_up(picture,player_color)
	
	entity_button.icon = texture
	#entity_button.disabled=true
	entity_button.name = "1"
	entity_button.visible = true
	var min_size: Vector2 = entity_button.get_minimum_size()
	entity_button.custom_minimum_size = min_size*1.5
	entity_button.expand_icon = true
	entity_button.text = entity["chassis"]
	entity_button.set_text_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	entity_button.set_icon_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	entity_button.set_vertical_icon_alignment(VERTICAL_ALIGNMENT_TOP)
	return entity_button
	

func _reset_hud() -> void:
	_make_hud_invisible(deployment_buttons)

func _check_phase(delta: float):
	pass

func _add_entity_buttons_for_player(delta: float)->void:
	if Global.active_player == null:
		return
	var player_name: String = Global.active_player.get_player_name()
	if len(active_deployment_buttons) > 0:
		if not active_deployment_buttons[0].begins_with(player_name):
			for button_name in active_deployment_buttons:
				deployment_buttons.remove_child(button_name)
				
	else:
		if player_name in deployment_buttons_dict.keys():
			for key in deployment_buttons_dict[player_name].keys():
				var button: Button = deployment_buttons_dict[player_name][key]
				button.set_name(player_name + "_" + key)
				deployment_buttons.add_child(button)

func _check_button_pressed(delta: float)->void:
	if Global.active_player == null:
		return
	var player_name: String = Global.active_player.get_player_name()
	if not player_name in deployment_buttons_dict.keys():
		return 
	var player_button_dict: Dictionary = deployment_buttons_dict[player_name]
	if len(player_button_dict) >0:
		for key in player_button_dict.keys():
			var button: Button = player_button_dict[key]
			if button.is_pressed():
				deployment_button_pressed.emit(player_name,key)
			

func _deploy_unit_recieved(player_name,unit_id)->void:
	if logo != null:
		logo.disabled = false
		current_unit = {CURR_PLAYER_KEY: player_name,CURR_UNIT_KEY:unit_id}

func _deployment_button_activate(delta: float)->void:
	if Global.controls != null:
		Global.controls.connect(UltraMekControls.DEPLOY_UNIT_SIGNAL,_deploy_unit_recieved)
		
func _deployment_button_press(delta: float)->void:
	if logo != null:
		if logo.disabled == false and logo.is_pressed():
			var curr_player: String = current_unit[CURR_PLAYER_KEY]
			var curr_unit: String = current_unit[CURR_UNIT_KEY]
			deploy_unit_confirmed.emit(curr_player,curr_unit)
			print("Deployment confirmed!")
			logo.disabled = true
			current_unit = {}
			deployment_buttons_dict[curr_player][curr_unit].disabled=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_phase(delta)
	_add_entity_buttons_for_player(delta)
	_check_button_pressed(delta)
	_deployment_button_activate(delta)
	_deployment_button_press(delta)
