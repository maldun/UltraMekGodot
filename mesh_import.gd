extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var file = FileAccess.open("res://hexa.json",FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var json_status = json.parse(text)
	var data = json.data
	print("Text: ",text,"json: ",data['verts'][1])
	
	for k in range(len(data['verts'])):
		var vert = data['verts'][k]
		verts.append(Vector3(vert[0],vert[2],vert[1]))
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
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1, 0)
	
	
	var top_surface_array = []
	top_surface_array.resize(Mesh.ARRAY_MAX)
	var top_verts = PackedVector3Array()
	var top_uvs = PackedVector2Array()
	var top_normals = PackedVector3Array()
	var top_indices = PackedInt32Array()
	
	for k in range(len(data['top_verts'])):
		var vert = data['top_verts'][k]
		top_verts.append(Vector3(vert[0],vert[2],vert[1]))
		var U = vert[0]+1.0
		var V = vert[1]+1.0
		var local_norm = 2 #(U**2+V**2)**0.5
		var uv_coord = Vector2(U/(local_norm),V/(local_norm))
		print("uv",k,": ",uv_coord)
		top_uvs.append(uv_coord)
		print("vert:",k,": ",vert)
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
	var material2 = StandardMaterial3D.new()
	var texture = preload("res://grass_h_swamp_0.png")
	material2.albedo_texture = texture
	mesh.surface_set_material(1,material2)
	mesh.surface_set_material(0,material)
	
	
	ResourceSaver.save(mesh, "res://hex.tres", ResourceSaver.FLAG_COMPRESS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
