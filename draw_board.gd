class_name Board
extends Node3D

const unit_length = 1.0
const unit_height = 0.5
const PNG = ".png"

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
	
	if ttype == "snow":
		texture_fname = get_snow_tile(height,rough,wood,swamp,water)
	
	if road[0] > 0:
		texture_fname = get_road_tile(texture_fname,road)
	
	texture_fname = folder + texture_fname
	print("texture fname: ",texture_fname)
	return load(texture_fname)
	
func get_road_tile(tile_fname: String, road) -> String:
	var fname: String = "road" + ("%02d" % road[1]) + "_" + tile_fname
	print("Road: ",fname)
	return "road/" + fname
			
func get_snow_tile(height: int,rough: int,wood: int,swamp: int,water: int) -> String:
	var rng = RandomNumberGenerator.new()
	
	#if wood > 0:
		#if wood == 1:
			#return "snow_l_woods_" + str(rng.randi_range(0,2)) + PNG
		#elif wood == 2:
			#return "snow_h_woods_" + str(rng.randi_range(0,2)) + PNG
	if rough > 0:
		return "snow_rough_" + str(rough) + PNG
	
	if water > 0:
		return "snow_water_" + str(water) + PNG
	
	return "snow_" + str(height) + PNG

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
	var s = UltraMekGD.new()
	s.set_unit_length(unit_length)
	var heights = data["heights"]
	var ttypes = data["tile_type"]
	var mat_map = create_material_map()
	var size_x = int(data["size_x"])
	var size_y = int(data["size_y"])
	var centers = s.create_grid_centers(size_x,size_y)
	print("Centers: ",len(centers))
	print("Dimx: ",size_x,"Dimy: ",size_y)
	
	# temp code 
	#var texture = preload(top_mat)
	#var rgb = Vector3(0,1,0)
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(rgb[0], rgb[1], rgb[2])
	#var material2 = StandardMaterial3D.new()
	#material2.albedo_texture = texture
	
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
	#create_board_from_file("res://test_json.json")
	pass
	
	#add_child(hex)
	#hex.create_hex(Vector2(2,2),"res://assets/hexes/hexa_h9.json",material,material2,0)
	
	#hex = Hex.new()
	#hex.set_name("Hex2")
	#hex.mesh = ArrayMesh.new()
	#hex.create_hex(Vector2(3,3),"res://assets/hexes/hexa_h9.json",material,material2,0)
	#add_child(hex)
func _recieved_board(recieved_map) -> void:
	#print("Recieved Map: ", recieved_map)
	create_board(recieved_map)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mm = get_tree().get_root().get_node("Main")
	var client_node = mm.get_node("TCPClient")
	await client_node.connect("recieved_board",_recieved_board)
	
