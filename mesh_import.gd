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
		print("vert:",k,": ",vert)
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
	material.albedo_color = Color(1, 0, 0)
	mesh.surface_set_material(0,material)
	ResourceSaver.save(mesh, "res://hex.tres", ResourceSaver.FLAG_COMPRESS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
