class_name DeploymentHud
extends UltraMekHud

const DEPLOYMENT_HUD_NODE: String = "DeploymentHud"
const DEPLOYMENT_BUTTON_NODE: String = "DeploymentButtons"
const CONTAINER_NAME: String = "CenterContainer"
const DEPLOYMENT_BILLBOARD: String = "res://assets/menu/deployment_phase_billboard.png"
const DEPLOYMENT_LOGO: String = "res://assets/menu/deploy.png"
const DEPLOYMENT_CONFIRM_BUTTON_NAME: String = "confirm_button"
const CURR_PLAYER_KEY: String = "curr_player"
const CURR_UNIT_KEY: String = "curr_unit"
const CURR_MAP_POS: String = "current_map_pos"

var preparation_hud: Node
var deployment_buttons: Node
var logo: Button = null

var current_phase: String
var deployment_buttons_dict: Dictionary
var active_deployment_buttons: Array = []
var current_unit = {}
var units2deploy: int = -1

const DEPLOYMENT_BUTTON_PRESSED_SIGNAL: String = "deployment_button_pressed"
signal deployment_button_pressed(player_name: String, button_id: String)

const DEPLOYMENT_UNIT_CONFIRMED_SIGNAL: String = "deploy_unit_confirmed"
signal deploy_unit_confirmed(player_name: String,unit_id: String,unit_pos: Vector3)

const DEPLOYMENT_FINISHED_SIGNAL: String = "deployment_finished_signal"
signal deployment_finished_signal



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	deployment_buttons = _ready_up_node(DEPLOYMENT_BUTTON_NODE)
	current_phase = Global.game_phase
	billboard_node = _make_start_screen(CONTAINER_NAME,DEPLOYMENT_BILLBOARD)
	deployment_buttons_dict = {}
	await _make_hud_invisible(deployment_buttons,"Deployment Hud invisible!")
	await _setup_deployment_hud()

#func _load_texture_from_extern(fname: String)-> ImageTexture:
	#var image = Image.load_from_file(fname)
	#var texture = ImageTexture.create_from_image(image)
	#return texture

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


func _setup_deployment_hud()->void:
	logo = Button.new()
	logo.icon = (load(DEPLOYMENT_LOGO))
	logo.set_name(DEPLOYMENT_CONFIRM_BUTTON_NAME)
	logo.disabled = true
	deployment_buttons.add_child(logo)
	
	if len(Global.players)>0:
		for player_id in Global.players.keys():
			deployment_buttons_dict[player_id] = {}
			var player: Player = Global.players[player_id]
			var player_picture_data: Dictionary = player.get_player_forces_images()
			for entity_key in player_picture_data.keys():
				var entity: Dictionary = player_picture_data[entity_key]
				#var entity: Dictionary = player_picture_data["1"]
				print("Player Picture Data: ",entity["gfx_2d_image"])
				var button: Button = _setup_entity_button(entity_key,player,entity)
				deployment_buttons_dict[player_id][entity_key]=button

func check_deployment_zone(player_id: String, unit_id: String, hex_coords: Vector2i)->bool:
	var player: Player = Global.players[player_id]
	var unit: UltraMekUnit = player.get_figure(unit_id)
	var depl_data: Dictionary = unit.get_deployment_data()
	var depl_width: int = int(depl_data[UltraMekUnit.DEPLOYMENT_WIDTH])
	var depl_offset: int = int(depl_data[UltraMekUnit.DEPLOYMENT_OFFSET])
	var depl_border: String = player.get_deployment_border()
	var height: int = Global.board_data[Board.SIZE_Y]
	var width: int = Global.board_data[Board.SIZE_X]
	
	var allowed_min_x: int = 0
	var allowed_max_x: int = width-1
	var allowed_min_y: int = 0
	var allowed_max_y: int = height-1
	
	if "S" in depl_border:
		allowed_min_y = depl_offset
		allowed_max_y = depl_offset + depl_width-1
	elif "N" in depl_border:
		allowed_min_y = height - depl_offset - depl_width
		allowed_max_y = height - depl_offset +1
	
	if "W" in depl_border:
		allowed_min_x = depl_offset-1
		allowed_max_x = depl_offset + depl_width-1
	elif "E" in depl_border:
		allowed_min_x = width - depl_offset - depl_width
		allowed_max_x = width - depl_offset
	#print("Check Deployment: ",hex_coords,"(",allowed_min_x,", ", allowed_max_x,") (",
	#allowed_min_y,", ",allowed_max_y,")")
	if allowed_min_x <= hex_coords[0] and hex_coords[0] <= allowed_max_x:
		if allowed_min_y <= hex_coords[1] and hex_coords[1] <= allowed_max_y:
			return true
	return false
		
func _setup_entity_button(entity_key: String, player: Player, entity: Dictionary)->Button:
	var entity_button: Button = Button.new()
	var picture: String = entity["gfx_2d_image"]
	#var texture = load("res://" + picture)
	var player_color: Color = player.get_player_color()
	var texture = UltraMekTools.color_up(picture,player_color)
	
	entity_button.icon = texture
	#entity_button.disabled=false
	entity_button.name = entity_key
	entity_button.visible = true
	var min_size: Vector2 = entity_button.get_minimum_size()
	entity_button.custom_minimum_size = min_size*1.5
	entity_button.expand_icon = true
	entity_button.text = entity["chassis"]
	entity_button.set_text_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	entity_button.set_icon_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	entity_button.set_vertical_icon_alignment(VERTICAL_ALIGNMENT_TOP)
	entity_button.flat = true
	return entity_button
	

func _reset_hud() -> void:
	_make_hud_invisible(deployment_buttons)

func get_nr_deployed_units(player_id: String,deployed: bool = true)->int:
	var player: Player = Global.players[player_id]
	var units: Dictionary = player.get_figures()
	var count: int = 0
	for unit_id in units.keys():
		var unit: UltraMekUnit = units[unit_id]
		if unit.get_deployment_status() == deployed:
			count += 1
	return count
	

func _check_phase(delta: float):
	var nr_deployed: int = 0
	for player_id in Global.players.keys():
		nr_deployed += get_nr_deployed_units(player_id,false)
	if nr_deployed == 0:
		deployment_finished_signal.emit()
		units2deploy = -1

func compute_units_to_deploy(player_name: String)->int:
	return 1

func _add_entity_buttons_for_player(delta: float)->void:
	if Global.active_player == null:
		return
	var active_player_name: String = Global.active_player.get_player_id()
	for player_name in deployment_buttons_dict.keys():
		for but in deployment_buttons_dict[player_name].keys():
			var button: Button = deployment_buttons_dict[player_name][but]
			var button_name: String = player_name + "_" + but
			if player_name == active_player_name:
				button.set_name(button_name)
				if deployment_buttons.get_node_or_null(button_name) == null:
						deployment_buttons.add_child(button)
			else:
				if deployment_buttons.get_node_or_null(button_name) != null:
					deployment_buttons.remove_child(button)

func _check_current_player()->void:
	if Global.active_player == null:
		return
	var player_name: String = Global.active_player.get_player_id()
	if units2deploy == -1:
		units2deploy = compute_units_to_deploy(player_name)
	elif units2deploy == 0:
		Global.next_player()
		units2deploy = -1

func _check_button_pressed(delta: float)->void:
	if Global.active_player == null:
		return
	var player_name: String = Global.active_player.get_player_id()
		
	if not player_name in deployment_buttons_dict.keys():
		return 
	var player_button_dict: Dictionary = deployment_buttons_dict[player_name]
	if len(player_button_dict) >0:
		for key in player_button_dict.keys():
			var button: Button = player_button_dict[key]
			if button.is_pressed():
				deployment_button_pressed.emit(player_name,key)
			

func _deploy_unit_recieved(player_name: String,unit_id:String, pos: Vector3)->void:
	if logo != null:
		logo.disabled = false
		current_unit = {CURR_PLAYER_KEY: player_name,CURR_UNIT_KEY:unit_id,
						CURR_MAP_POS:pos}


func _deployment_button_activate(delta: float)->void:
	if Global.controls != null:
		if not Global.controls.is_connected(UltraMekControls.DEPLOY_UNIT_SIGNAL,_deploy_unit_recieved):
			Global.controls.connect(UltraMekControls.DEPLOY_UNIT_SIGNAL,_deploy_unit_recieved)
		
func _deployment_button_press(delta: float)->void:
	if logo != null:
		if logo.disabled == false and logo.is_pressed():
			var curr_player: String = current_unit[CURR_PLAYER_KEY]
			var curr_unit: String = current_unit[CURR_UNIT_KEY]
			var curr_pos: Vector3 = current_unit[CURR_MAP_POS]
			deploy_unit_confirmed.emit(curr_player,curr_unit,curr_pos)
			#print("Deployment confirmed!")
			logo.disabled = true
			current_unit = {}
			deployment_buttons_dict[curr_player][curr_unit].disabled=true
			units2deploy -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_phase(delta)
	_billboard_phase_out(delta,CONTAINER_NAME,deployment_buttons,"buttons visible!")
	_add_entity_buttons_for_player(delta)
	_check_button_pressed(delta)
	_check_current_player()
	_deployment_button_activate(delta)
	_deployment_button_press(delta)
