extends Node3D

const unit_length = 1.0
const unit_height = 0.5

const top_mat = "res://grass_h_swamp_0.png"
const color_norm = 255

const type_map = {"snow":Vector3(204,255,255)/color_norm,
				  "grass":Vector3(0,255,0)/color_norm
				}
				
const texture_folders = {"snow":"res://assets/hexes/snow/",
				  "grass": "res://assets/hexes/grass/"
				}

func get_json_data(fname: String) -> Dictionary:
	var file = FileAccess.open(fname,FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var json_status = json.parse(text)
	var data = json.data
	return data
	
func create_material_map() -> Dictionary:
	var materials = {}
	for key in type_map.keys():
		var rgb = type_map[key]
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(rgb[0], rgb[1], rgb[2])
		materials[key] = mat
	return materials
	
func get_texture(data: Dictionary,xi: int,yj: int):
	var ttype: String = data["tile_type"][xi][yj]
	var height: int = int(data["heights"][xi][yj])
	var rough: int = int(data["rough"][xi][yj])
	var wood: int = int(data["woods"][xi][yj])
	var swamp: int = int(data["swamp"][xi][yj])
	
	
	if ttype == "snow":
		return get_snow_tile(height,rough,wood,swamp)
	
	
			
func get_snow_tile(height,rough,wood,swamp):
	var folder = texture_folders["snow"]
	if wood > 0:
		if wood == 1:
			return folder + "snow_lf.png"
		elif wood == 2:
			return folder + "snow_hf.png"
	if rough > 0:
		return folder + "snow_rough_" + str(rough) + ".png"
		
	return folder + "snow_" + str(height) + ".png"
	
func create_board(fname: String) -> void:
	# set cpp helpers
	var s = UltraMekGD.new()
	s.set_unit_length(unit_length)
	var data = get_json_data(fname)
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
	print("form string: ", format_x)
	
	
	var mat_count = 0
	for i in range(size_x):
		for j in range(size_y):
			var x = centers[i][j][0]
			var y = centers[i][j][1]
			var height = heights[i][j]
			#print("Height: ",height," i: ",i," j: ",j," x: ",x," y: ",y)
			var json_name = "res://assets/hexes/hexa_h{hh}.json".format({"hh":height})
			var material = mat_map[ttypes[i][j]]
			var texture_fname = get_texture(data,i,j)
			var texture = load(texture_fname)
			var material2 = StandardMaterial3D.new()
			material2.albedo_texture = texture
			
			var hex = Hex.new()
			var hex_name: String = "Hex" + (format_x % i) + (format_y % j)
			hex.set_name(hex_name)
			hex.mesh = ArrayMesh.new()
			hex.material = material
			
			
			hex.create_hex(Vector2(x,y),json_name,material,material2,mat_count)
			add_child(hex)
			#mat_count += 1
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_board("res://test_json.json")
	
	#add_child(hex)
	#hex.create_hex(Vector2(2,2),"res://assets/hexes/hexa_h9.json",material,material2,0)
	
	#hex = Hex.new()
	#hex.set_name("Hex2")
	#hex.mesh = ArrayMesh.new()
	#hex.create_hex(Vector2(3,3),"res://assets/hexes/hexa_h9.json",material,material2,0)
	#add_child(hex)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
