extends MeshInstance3D

const unit_length = 1.0
const unit_height = 0.5

const top_mat = "res://grass_h_swamp_0.png"
const color_norm = 255

const type_map = {"snow":Vector3(204,255,255)/color_norm,
				  "grass":Vector3(0,255,0)/color_norm
				}
				
var texture = preload(top_mat)
var rgb = Vector3(0,1,0)
var material = StandardMaterial3D.new()
var material2 = StandardMaterial3D.new()

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
	var texture = preload(top_mat)
	var rgb = Vector3(0,1,0)
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(rgb[0], rgb[1], rgb[2])
	var material2 = StandardMaterial3D.new()
	material2.albedo_texture = texture
	
	var mat_count = 0
	for i in range(size_x):
		for j in range(size_y):
			var x = centers[i][j][0]
			var y = centers[i][j][1]
			var height = heights[i][j]
			print("Height: ",height," i: ",i," j: ",j," x: ",x," y: ",y)
			var json_name = "res://assets/hexes/hexa_h{hh}.json".format({"hh":height})
			var material = mat_map[ttypes[i][j]]
			create_hex(Vector2(x,y),json_name,material,material2,mat_count)
			mat_count += 1
	print("Count: ",mat_count)

func create_hex(center: Vector2,hex_fname: String,bot_mat,top_mat,mat_count: int) -> void:
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	#var file = FileAccess.open(hex_fname,FileAccess.READ)
	#var text = file.get_as_text()
	#var json = JSON.new()
	#var json_status = json.parse(text)
	var data = get_json_data(hex_fname)
	
	for k in range(len(data['verts'])):
		var vert = data['verts'][k]
		verts.append(Vector3(vert[0]+center[0],vert[2],vert[1]+center[1]))
		#print("vert:",k,": ",vert)
	for k in range(len(data['normals'])):
		var normal = data['normals'][k]
		normals.append(Vector3(normal[0],normal[2],normal[1]))
	for k in range(len(data['order'])):
		indices.append(data['order'][k])
	
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	#surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	# top surface
	var top_surface_array = []
	top_surface_array.resize(Mesh.ARRAY_MAX)
	var top_verts = PackedVector3Array()
	var top_uvs = PackedVector2Array()
	var top_normals = PackedVector3Array()
	var top_indices = PackedInt32Array()
	
	for k in range(len(data['top_verts'])):
		var vert = data['top_verts'][k]
		var unit_length = float(data['length'])
		top_verts.append(Vector3(vert[0]+center[0],vert[2],vert[1]+center[1]))
		var uv = data['top_uv'][k]
		var uv_coord = Vector2(uv[0],uv[1])
		#print("uv",k,": ",uv_coord)
		top_uvs.append(uv_coord)
		#print("vert:",k,": ",vert)
	for k in range(len(data['top_normals'])):
		var normal = data['top_normals'][k]
		top_normals.append(Vector3(normal[0],normal[2],normal[1]))
	for k in range(len(data['top_order'])):
		top_indices.append(data['top_order'][k])
	
	top_surface_array[Mesh.ARRAY_VERTEX] = top_verts
	top_surface_array[Mesh.ARRAY_TEX_UV] = top_uvs
	top_surface_array[Mesh.ARRAY_NORMAL] = top_normals
	top_surface_array[Mesh.ARRAY_INDEX] = top_indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, top_surface_array)
	
	mesh.surface_set_material(2*(mat_count+1)-1,top_mat)
	mesh.surface_set_material(2*(mat_count+1)-2,bot_mat)
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	material.albedo_color = Color(rgb[0], rgb[1], rgb[2])
	material2.albedo_texture = texture
	
	#create_hex(Vector2(1,1),"res://hexa_h9.json",material,material2)
	create_board("res://test_json.json")
	ResourceSaver.save(mesh, "res://map.tres", ResourceSaver.FLAG_COMPRESS)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
