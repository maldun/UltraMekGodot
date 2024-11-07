class_name Board
extends Node3D

const unit_length: float = Global.UNIT_LENGTH
const unit_height: float = Global.UNIT_HEIGTH
const PNG: String = ".png"

const top_mat = "res://grass_h_swamp_0.png"
const color_norm = 255

const type_map = {"snow":Vector3(204,255,255)/color_norm,
				  "grass":Vector3(0,255,0)/color_norm
				}
				
				
				
				
const texture_folders = {"snow":"res://assets/hexes/snow/",
				  "grass": "res://assets/hexes/grass/"
				}

var flat: bool = false
var flat_level: int = -2
	
func create_material_map() -> Dictionary:
	var materials = {}
	
	
	for key in type_map.keys():
		var rgb = type_map[key]
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(rgb[0], rgb[1], rgb[2])
		materials[key] = mat
	return materials
	
func draw_texture(data: Dictionary,xi: int,yj: int):
	var ttype: String = data["tile_type"][xi][yj]
	var height: int = int(data["heights"][xi][yj])
	var rough: int = int(data["rough"][xi][yj])
	var wood: int = int(data["woods"][xi][yj])
	var swamp: int = int(data["swamp"][xi][yj])
	var water: int = int(data["water"][xi][yj])
	var road = data["road"][xi][yj]
	var texture_fname: String
	var folder = texture_folders[ttype]
	var asset_folder: String = "res://assets/hexes/"
	var asset_data_dict = DataHandler.get_json_data(asset_folder + "tiles.json")
	var asset_data = DataHandler.get_json_data(asset_data_dict[ttype])
	#if ttype == "snow":
	texture_fname = get_tile(asset_data,height,rough,wood,swamp,water,road)
	
	print("texture fname: ",texture_fname)
	return load(texture_fname)
	
func get_road_tile(tile_fname: String, road) -> String:
	var fname: String = "road" + ("%02d" % road[1]) + "_" + tile_fname
	print("Road: ",fname)
	return fname
			
func get_tile(asset_data: Dictionary, height: int,rough: int,wood: int,swamp: int,water: int,
			  road) -> String:
	var rng = RandomNumberGenerator.new()
	var tile_data = asset_data["tiles"]
	#if wood > 0:
		#if wood == 1:
			#return "snow_l_woods_" + str(rng.randi_range(0,2)) + PNG
		#elif wood == 2:
			#return "snow_h_woods_" + str(rng.randi_range(0,2)) + PNG
	var texture_fname = tile_data["default"][str(height)]
	
	if rough > 0:
		print("Rough: ", rough)
		if "rough" in tile_data.keys():
			if str(rough) in tile_data["rough"].keys():
				texture_fname = tile_data["rough"][str(rough)]
	
	if water > 0:
		if "water" in tile_data.keys():
			if str(water) in tile_data["water"].keys():
				texture_fname = tile_data["water"][str(water)]
	
	#print("Road: ",road)
	if road[0] > 0:
		texture_fname = get_road_tile(texture_fname,road)
		texture_fname = asset_data["roads"] + texture_fname
	else:
		texture_fname = asset_data["texture_folder"] +texture_fname
		
	return texture_fname 

func label_text(data: Dictionary,i: int ,j: int) -> String:
	var water: int = data["water"][i][j]
	var height: int = data["heights"][i][j]
	var rough: int = data["rough"][i][j]
	var woods: int = data["woods"][i][j]
	var label: String = ""
	
	if water > 0:
		label = label + "Depth " + str(water) + "\n"
	elif rough > 0:
		label += "Rough\n"
	elif woods > 0:
		label += "Woods" + str(woods) + "\n"
		
	label += "Lvl" + str(height)
	return label


func create_board_from_file(fname: String)-> void:
	var data: Dictionary = DataHandler.get_json_data(fname)
	create_board(data)

func create_board(data: Dictionary) -> void:
	# set cpp helpers
	var s: UltraMekGD = Global.ultra_mek_cpp
	
	var heights = data["heights"]
	var ttypes = data["tile_type"]
	var mat_map = create_material_map()
	var size_x = int(data["size_x"])
	var size_y = int(data["size_y"])
	var centers = s.setup_board_geometry(size_x,size_y,unit_length,unit_height)
	# = s.get_grid_centers()#(size_x,size_y)
	#print("Centers: ",centers)
	#print("Dimx: ",size_x,"Dimy: ",size_y)
	#print("Test Vector: ",s.compute_euclidean(3.0,4.0)==5.0)
	#var dim_x: int = 3
	#var dim_y: int = 3
	#var warrr: Array = [0,1,2,10,1,1,2,1,1]
	#print("Test Board Graph Creation: ",s.create_board_graph(dim_x,dim_y,warrr))
	#print("Test Board Graph Path: ",s.compute_shortest_walk_ids(0,8))
	# send data to main
	Global.processed_board_data.emit(size_x,size_y)
	print("Alert: board_data_sent")
	
	var num_zeros_x: int = int(floor(log(size_x)/log(10)))+1
	var num_zeros_y: int  = int(floor(log(size_y)/log(10)))+1 
	
	var format_x: String = "%0" + str(num_zeros_x) + "d"
	var format_y: String = "%0" + str(num_zeros_y) + "d"
	#print("form string: ", format_x)
	for i in range(size_x):
		for j in range(size_y):
			var x = centers[i][j][0]
			var y = centers[i][j][1]
			var height = heights[i][j]
			#print("Height: ",height," i: ",i," j: ",j," x: ",x," y: ",y)
			var json_name: String = "res://assets/hexes/hexa_h{hh}.json"
			if flat == false:
				json_name = json_name.format({"hh":height})
			else:
				json_name = json_name.format({"hh":flat_level})
			var material = mat_map[ttypes[i][j]]
			var texture = draw_texture(data,i,j)
			
			var material2 = StandardMaterial3D.new()
			material2.albedo_texture = texture
			
			var hex = Hex.new()
			var hex_name: String = "Hex" + (format_x % i) + (format_y % j)
			hex.set_name(hex_name)
			hex.mesh = ArrayMesh.new()
			hex.material = material
			
			hex.create_hex(Vector2(x,y),json_name,material,material2)
			var text_color: Color = Color(1,1,1)
			var label_text: String = label_text(data,i,j)
			hex.add_label(label_text,text_color)
			
			# generate decorations
			hex.generate_decoration(data,i,j)
			hex.create_convex_collision()
			add_child(hex)
	
	
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
func _recieved_board(recieved_map) -> void:
	print("Recieved Map: ", recieved_map)
	Global.board_data = recieved_map
	create_board(recieved_map)

func _rotate_deployment_pointer(player_name: String, unit_id: String, pos: Vector3, mouse_pos:Vector2):
	var player: Player = Global.players[player_name]
	var pointer: UltraMekDirectionPointer = null
	if player.pointer_exists(unit_id):
		pointer = player.get_pointer(unit_id)
	else:
		pointer = player.add_pointer(unit_id)
		add_child(pointer)
		pointer.place(player_name,unit_id,pos)
		pointer.set_global_position(pos)
		
	
	var phi: Global.DIRECTIONS = pointer.compute_dir_from_mouse_position(mouse_pos)
	#print("rotate pointer!",mouse_pos,phi,"atan2: ",atan2(mouse_pos[0],mouse_pos[1]))
	pointer.rotate_pointer(phi)
	
func _deploy_unit(player_name: String, unit_id: String, pos: Vector3):
	var fig: Node = Global.players[player_name].add_figure(unit_id)
	add_child(fig)
	fig.set_global_position(pos)
	fig.deploy(player_name,unit_id,pos)

func _remove_pointer(player_name: String, unit_id: String):
	var player: Player = Global.players[player_name]
	var pointer: UltraMekDirectionPointer = null
	if player.pointer_exists(unit_id):
		pointer = player.get_pointer(unit_id)
		remove_child(pointer)
		player.remove_pointer(unit_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var mm = get_tree().get_root().get_node(UltraMekMain.NODE_NAME)
	#print("Main Variables: ",mm.ultra_mek_cpp.get_unit_length())
	#var client_node = mm.get_node(mm.TCP_NODE_NAME)
	
	var client_node = Global.game_client
	if client_node != null:
		await client_node.connect("recieved_board",_recieved_board)
		
	if Global.controls != null:
		Global.controls.connect(UltraMekControls.ROTATE_DEPL_POINTER_SIGNAL,_rotate_deployment_pointer)
		Global.controls.connect(UltraMekControls.REMOVE_POINTER_SIGNAL,_remove_pointer)
		
	if Global.main != null:
		Global.main.connect(UltraMekMain.DEPLOY_UNIT_SIGNAL,_deploy_unit)
	
