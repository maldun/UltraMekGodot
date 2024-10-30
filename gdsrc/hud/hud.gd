extends Control

const DEPLOYMENT_HUD_NODE: String = "CanvasLayer/DeploymentHud"

var preparation_hud: Node
var deployment_hud: Node

var current_phase: String

var main_node: Node = null

func _ready_up_node(name: String) -> Node:
	var node: Node = get_node(name)
	node.visible = false
	return node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	deployment_hud = _ready_up_node(DEPLOYMENT_HUD_NODE)
	current_phase = Global.game_phase
		
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

func _setup_deployment_hud(delta: float)->void:
	if len(Global.players)>0:
		var player_picture_data: Dictionary = Global.players["player1"].get_player_forces_images()
		var picture: String = player_picture_data["1"]["gfx_2d_image"]
		print("Player Picture Data: ",player_picture_data["1"]["gfx_2d_image"])
		var player_button: TextureButton = TextureButton.new()
		var texture = _load_texture_from_extern(picture)
		player_button.texture_normal = texture
		player_button.texture_disabled = to_grey_scale(picture)
		player_button.disabled=true
		player_button.name = "1"
		player_button.visible = true
		deployment_hud.add_child(player_button)
		
func _reset_hud() -> void:
	_make_hud_invisible(deployment_hud)

func _check_phase(delta: float):
	if current_phase != Global.game_phase:
		current_phase = Global.game_phase
		_reset_hud()
		
		if Global.game_phase == Global.PREPARATION_PHASE:
			pass
		if Global.game_phase == Global.DEPLOYMENT_PHASE:
			await _make_hud_visible(deployment_hud,"Deployment Hud visible!")
			await _setup_deployment_hud(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_phase(delta)
	pass
