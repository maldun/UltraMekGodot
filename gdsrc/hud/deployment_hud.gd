extends Control

const DEPLOYMENT_HUD_NODE: String = "DeploymentHud"
const DEPLOYMENT_BUTTON_NODE: String = "DeploymentButtons"
const DEPLOYMENT_LOGO: String = "res://assets/menu/deploy.png"

var preparation_hud: Node
var deployment_buttons: Node

var current_phase: String
var deployment_buttons_dict: Dictionary

var main_node: Node = null

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

func _setup_deployment_hud()->void:
	var logo: TextureRect = TextureRect.new()
	logo.set_texture(load(DEPLOYMENT_LOGO))
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
	var texture = load("res://" + picture)
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
	deployment_buttons.add_child(entity_button)
	return entity_button
	

func _reset_hud() -> void:
	_make_hud_invisible(deployment_buttons)

func _check_phase(delta: float):
	pass
	#if current_phase != Global.game_phase:
	#	current_phase = Global.game_phase
	#	_reset_hud()
		
		#if Global.game_phase == Global.PREPARATION_PHASE:
		#	pass
		#if Global.game_phase == Global.DEPLOYMENT_PHASE:
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_phase(delta)
	pass
