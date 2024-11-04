class_name UltraMekUnit
extends Node3D

const SPAWN_ANIMATION_PREFIX: String = "Spawn_"
const MESH_PREFIX: String = "Figure_Mesh_"
const MESH_POINTER: String = "Figure_Pointer_"
const SMOKE_SCENE: String = "res://gdsrc/board/smoke_3d.tscn"
const SMOKE_NODE: String = "SmokeParticles"
const DEPLOYMENT_TIMEOUT = 3


var gfx_provided = false
var figure_created: bool = false
var figure_deployed: bool = false
var spawn_animation: Node3D = null
var player: Player
var unit_data: Dictionary
var unit_direction: Global.DIRECTIONS = Global.DIRECTIONS.N
var unit_id: String
var current_pos: Vector3
var timer: float = 0
var pointer: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	figure_created = false

func get_spawn_animation_name()->String:
	return SPAWN_ANIMATION_PREFIX + "_" + player.get_player_name() + "_" + unit_id

func get_figure_mesh_name()->String:
	return MESH_PREFIX + "_" + player.get_player_name() + "_" + unit_id
	
func get_pointer_name()->String:
	return MESH_POINTER + "_" + player.get_player_name() + "_" + unit_id

func deploy(player_name: String, unit_id_name: String, pos: Vector3)->void:
	figure_created = true
	player = Global.players[player_name]
	unit_id = unit_id_name
	current_pos = pos
	var scene = load(SMOKE_SCENE)
	spawn_animation = scene.instantiate()
	spawn_animation.set_name(get_spawn_animation_name())
	add_child(spawn_animation)
	spawn_animation.set_global_position(pos)
	figure_deployed = true
	
	pointer = create_direction_pointer(pos)
	pointer.set_name(get_pointer_name())
	add_child(pointer)
	

func put_figure_on_board(delta: float)->void:
	if gfx_provided == false:
		var dummy = _create_dummy(delta)
		add_child(dummy)
		dummy.set_global_position(current_pos)
	

func create_direction_pointer(pos: Vector3)->MeshInstance3D:
	const HEIGHT: float = Hex.unit_height/8
	const WIDTH: float = Hex.unit_length
	const LENGTH: float = Hex.unit_length/8
	const SUB_DIVISIONS: int = 2
	var rgb = Color(0,0,5.0,0.5)
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
	
	var dir = Global.DIRECTIONS.S
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
		

func _create_dummy(delta: float)->Node3D:
	var dummy = StandeePrimitive.new()
	var color: Color = player.get_player_color()
	var image_data: Dictionary = player.get_player_forces_images()
	var texture_img = image_data[unit_id][Player.IMAGE_2D_KEY]
	dummy.init_standee(texture_img,color)
	dummy.set_name(get_figure_mesh_name())
	return dummy

func _deploy_time_out(delta: float)->void:
	if figure_deployed == true:
		var spawn_animation: Node3D = find_child(get_spawn_animation_name(),true,false)
		if timer < DEPLOYMENT_TIMEOUT:
			timer += delta
			var smoke: Node3D = spawn_animation.find_child(SMOKE_NODE,true,false)
			smoke.amount_ratio = (DEPLOYMENT_TIMEOUT-timer)/DEPLOYMENT_TIMEOUT
		else:
			timer = 0
			figure_deployed = false
			put_figure_on_board(delta)
			remove_child(spawn_animation)
			
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.main != null and Global.board != null:
		_deploy_time_out(delta)
		
			
