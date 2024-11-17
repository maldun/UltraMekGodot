class_name UltraMekDirectionPointer
extends Node3D

const MESH_POINTER: String = "Mesh_Pointer_"
const POINTER_PREFIX: String = "Figure_Pointer_"

var player: Player
var unit_data: Dictionary
var pointer_direction: Global.DIRECTIONS = Global.DIRECTIONS.S
var unit_id: String
var current_pos: Vector3
var pointer: MeshInstance3D

func place(player_id: String, unit_id_name: String, pos: Vector3)->void:
	player = Global.players[player_id]
	unit_id = unit_id_name
	current_pos = pos
	
	pointer_direction = Global.DIRECTIONS.S
	pointer = create_direction_pointer(Vector3(0,0,0),pointer_direction)
	pointer.set_name(get_mesh_pointer_name())
	add_child(pointer)
	set_global_position(pos)
	

func get_mesh_pointer_name()->String:
	return MESH_POINTER + "_" + player.get_player_id() + "_" + unit_id
	
func get_pointer_name(player_id: String = "", unit_id_: String = "")->String:
	if player_id == "":
		player_id = player.get_player_id()
	if unit_id_ == "":
		unit_id_ = unit_id
	return POINTER_PREFIX + "_" + player_id + "_" + unit_id_

func create_direction_pointer(pos: Vector3, dir: Global.DIRECTIONS)->MeshInstance3D:
	const HEIGHT: float = Hex.unit_height/8
	const WIDTH: float = Hex.unit_length
	const LENGTH: float = Hex.unit_length/8
	const SUB_DIVISIONS: int = 2
	var rgb = Color(player.get_player_color(),0.8)
	var mat = StandardMaterial3D.new()
	mat.set_albedo(rgb)
	mat.set_metallic(0.5)
	mat.set_transparency(1)
	mat.backlight_enabled = true
	mat.set_backlight(Color(1,1,1,1))
	
	var mesh = PrismMesh.new()
	mesh.set_size(Vector3(WIDTH,LENGTH,HEIGHT))
	mesh.set_subdivide_depth(SUB_DIVISIONS)
	mesh.set_subdivide_height(SUB_DIVISIONS)
	mesh.set_subdivide_width(SUB_DIVISIONS)
	
	for k in range(5):
		mesh.surface_set_material(k,mat)
	
	var pointer_node: MeshInstance3D = MeshInstance3D.new()
	pointer_node.set_mesh(mesh)
	
	var cpos: Vector3 = compute_pointer_position(dir)
	pointer_node.set_global_position(cpos)
	pointer_node.rotate_x(PI/2)
	pointer_node.rotate_y(compute_pointer_rotation_y(dir))
	return pointer_node

func compute_pointer_position(direction: Global.DIRECTIONS) -> Vector3:
	var new_pos: Vector3 = Vector3(0,0,0)
	new_pos[0] += 0.8*Hex.unit_length*cos(direction*PI/3+PI/6)
	new_pos[1] += -1.9*Hex.unit_height
	new_pos[2] += 0.8*Hex.unit_length*sin(direction*PI/3+PI/6)
	return new_pos
	
func compute_pointer_rotation_y(direction: Global.DIRECTIONS) -> float:
	if direction == Global.DIRECTIONS.N or direction == Global.DIRECTIONS.S:
		return direction*PI/3-PI/3
	elif direction == Global.DIRECTIONS.SW or direction==Global.DIRECTIONS.NE:
		return direction*PI/3+PI
	else:
		return direction*PI/3+PI/3

func place_direction_pointer(direction: Global.DIRECTIONS)->void:
	if pointer != null:
		pointer.set_global_position(compute_pointer_position(direction))
		pointer.rotate_y(direction*PI/3+PI/6)
		
func rotate_pointer(direction: Global.DIRECTIONS)->void:
	if pointer != null:
		var rot: float = compute_pointer_rotation_y(pointer_direction)
		rotate_y(-rot)
		rot = compute_pointer_rotation_y(direction)
		rotate_y(rot)
		pointer_direction = direction

static func compute_dir_from_mouse_position(pos: Vector2)->Global.DIRECTIONS:
	var phi: float = atan2(pos[0],pos[1])
	if phi < 0:
		phi += 2*PI
	if 0<= phi and phi < PI/3:
		return Global.DIRECTIONS.SE
	elif PI/3 <= phi and phi < 2*PI/3:
		return Global.DIRECTIONS.NE
	elif 2*PI/3 <= phi and phi < PI:
		return Global.DIRECTIONS.N
	elif PI <= phi and phi < 4*PI/3:
		return Global.DIRECTIONS.NW
	elif 4*PI/3 <= phi and phi < 5*PI/3:
		return Global.DIRECTIONS.SW
	else:
		return Global.DIRECTIONS.S


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
