class_name Hex
extends MeshInstance3D

const unit_length = Global.UNIT_LENGTH
const unit_height = Global.UNIT_HEIGTH
const PI = atan(1)*4

const top_mat = "res://grass_h_swamp_0.png"
const color_norm = 255

const type_map = {"snow":Vector3(204,255,255)/color_norm,
				  "grass":Vector3(0,255,0)/color_norm
				}
				
var texture = preload(top_mat)
var rgb: Vector3 = Vector3(0,1,0)
var material = StandardMaterial3D.new()
var material2 = StandardMaterial3D.new()
var hex_center: Vector2
var hex_height: float

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
		

func create_hex(center: Vector2,hex_fname: String,bot_mat,top_mat,mat_count: int = 0) -> void:
	
	hex_center = center
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
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
	
	hex_height = data['top_verts'][0][2]
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
	
func add_label(label: String, color: Color)-> void:
	var label3d = Label3D.new()
	label3d.text = label
	label3d.name = "Label" + name
	var pos: Vector3 = Vector3(hex_center[0],hex_height*1.01,hex_center[1])
	pos[2] = pos[2]+unit_length/2.0
	label3d.set_position(pos)
	#label3d.set_global_position(pos)
	add_child(label3d)
	label3d.rotate_x(PI/2)
	label3d.rotate_y(PI)
	label3d.rotate_z(PI)
	label3d.set("theme_override_colors/font_color",color)
	

func generate_decoration(data: Dictionary,i:int,j:int) -> void:
	var wood: int = int(data["woods"][i][j]) 
	var rough: int = int(data["rough"][i][j]) 
	var ttype: String = data["tile_type"][i][j]
	
	if wood > 0:
		generate_forest(ttype,wood)
	if rough > 0:
		generate_rough(ttype,rough)
		
func create_rotation_points_on_top(nr: int,shift: float = 0,
			shorten_radius:float = 0.75)-> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	var angle: float = 2*PI/nr
	var R: float = unit_length*shorten_radius
	for k in range(nr):
		result.append(R*Vector2(cos(k*angle+shift),sin(k*angle+shift)))

	return result

func generate_forest(ttype:String,wood:int) -> void:
	var light_wood:bool = true if wood == 1 else false
	var scenes = await Forest.generate(ttype,self,light_wood)
	var nr_trees = (Forest.NR_TREES_LIGHT if light_wood == true 
					else Forest.NR_TREES_HEAVY)
	var coords = await create_rotation_points_on_top(nr_trees)
	for k in range(len(scenes)):
		var scene = scenes[k]
		var c: Vector2 = coords[k]
		#scene.global_transform.origin = 
		scene.translate(Vector3(hex_center[0]+c[0],hex_height,
								hex_center[1]+c[1]))
		
		await add_child(scene)

func generate_rough(ttype:String,rough:int) -> void:
	var light_rough:bool = true if rough == 1 else false
	var scenes = Rough.generate(ttype,self,light_rough)
	var nr_stones = (Rough.NR_STONES_LIGHT if light_rough == true 
					else Rough.NR_STONES_LIGHT)
	var coords = create_rotation_points_on_top(nr_stones,0)
	
	for k in range(len(scenes)):
		var scene = scenes[k]
		var c: Vector2 = coords[k]
		#scene.global_transform.origin = 
		scene.translate(Vector3(hex_center[0]+c[0],hex_height,
								hex_center[1]+c[1]))
		add_child(scene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#create_hex(center,"res://assets/hexes/hexa_h9.json",material,material2,0)
	#ResourceSaver.save(mesh, "res://map.tres", ResourceSaver.FLAG_COMPRESS)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
