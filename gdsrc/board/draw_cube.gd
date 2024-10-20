extends MeshInstance3D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	# I like to use this convention, but you can use whatever you like
#               010           110                         Y
#   Vertices     A0 ---------- B1            Faces      Top    -Z
#           011 /  |      111 /  |                        |   North
#             E4 ---------- F5   |                        | /
#             |    |        |    |          -X West ----- 0 ----- East X
#             |   D3 -------|-- C2                      / |
#             |  /  000     |  / 100               South  |
#             H7 ---------- G6                      Z    Bottom
#              001           101                          -Y

	var a := Vector3(0, 1, 0) # if you want the cube centered on grid points
	var b := Vector3(1, 1, 0) # you can subtract a Vector3(0.5, 0.5, 0.5)
	var c := Vector3(1, 0, 0) # from each of these
	var d := Vector3(0, 0, 0)
	var e := Vector3(0, 1, 1)
	var f := Vector3(1, 1, 1)
	var g := Vector3(1, 0, 1)
	var h := Vector3(0, 0, 1)

	var vertices := [   # faces (triangles)
		b,a,d,  b,d,c,  # N
		e,f,g,  e,g,h,  # S
		a,e,h,  a,h,d,  # W
		f,b,c,  f,c,g,  # E
		a,b,f,  a,f,e,  # T
		h,g,c,  h,c,d,  # B
	]

	var colors := []
	for i in range(vertices.size()):
		colors.append(Color.RED)

	var mesh := ArrayMesh.new()

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	arrays[Mesh.ARRAY_COLOR] =  PackedColorArray(colors)

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	ResourceSaver.save(mesh, "res://{name}.tres".format({"name": "cube"}), ResourceSaver.FLAG_COMPRESS)
	# mesh.surface_set_material(0, your_material)   # will need uvs if using a texture
	#your_material.vertex_color_use_as_albedo = true # will need this for the array of colors

	#var mi := MeshInstance.new()
	#mi.mesh = mesh
	#add_child(mi) # don't forget to add it as child of something (I always forget, lol)

	# if the texture is a tileset like minecraft's, then maybe you can use this 
	# instead of setting the material for each surface
	# mi.material_override = your_material      # will need uvs if using a texture	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
