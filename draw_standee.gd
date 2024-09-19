class_name StandeePrimitive
extends MeshInstance3D

var hex: Hex
var center: Vector3

func create_standee(fname: String):
	
	var s = UltraMekGD.new()
	s.set_unit_length(Hex.unit_length)
	var data = DataHandler.get_json_data(fname)
	print("Data: ",data.keys())
	var heights = data["height"]
	
	var centers = s.create_grid_centers(2,2)
	var center = centers[0][0]
	
	# 
	hex = Hex.new()
	var hex_name = "Standee"
	var material2 = StandardMaterial3D.new()
	var texture = load("res://Atlas_7DR.png")
	material2.albedo_texture = texture
	
	var material = StandardMaterial3D.new()
	var rgb: Color = Color(1,0,0)
	material.albedo_color = Color(rgb[0], rgb[1], rgb[2])
	hex.set_name(hex_name)
	hex.mesh = ArrayMesh.new()
	hex.material = material
	
	hex.create_hex(center,fname,material,material2)
	hex.scale = Vector3(0.5,0.1,0.5)
	hex.create_convex_collision()
	var height = hex.hex_height
	add_child(hex)
	return Vector3(center[0],height,center[1])
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center = create_standee("res://assets/hexes/hexa_h-5.json")
	#global_translate(center)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
