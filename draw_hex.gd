extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await draw_hex("hex")

func draw_hex(name):
	var um = UltraMekGD.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	var colors := []
	
	var vertices =  um.create_hex_vertices(0,0,1,1)
	var order = um.create_vertex_order()
	#order   = [0, 1, 2, 
			   #0, 2, 3, 
			   #0, 3, 4, 
			   #0, 4, 5, 
			   #0, 5, 6, 
			   #0, 6, 1, 
			   #7, 8, 9, 
			   #7, 9, 10, 
			   #7, 10, 11, 
			   #7, 11, 12, 
			   #7, 12, 13, 
			   #7, 13, 8, 
			   #1, 8, 2, 
			   ##2, 8, 3
			   #]
	for i in range(len(vertices)):
		verts.append(vertices[i])
		if i < 7:
			normals.append(Vector3(0,0,-1))
		else:
			normals.append(Vector3(0,0,1))
			
		#indices.append(order[0+i*3])
		#indices.append(order[1+i*3])
		#indices.append(order[2+i*3])
		uvs.push_back(Vector2(0,1))
		colors.append(Color.RED)
	for i in range(len(order)):
		indices.append(order[i])
		
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	#surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_COLOR] =  PackedColorArray(colors)
	
	print("Vertices: ", vertices)
	print("Indices: ", indices)

	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	# Saves mesh to a .tres file with compression enabled.
	ResourceSaver.save(mesh, "res://{name}.tres".format({"name": name}), ResourceSaver.FLAG_COMPRESS)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
