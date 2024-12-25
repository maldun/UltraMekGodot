class_name UltraMekUnit
extends Node3D

const SPAWN_ANIMATION_PREFIX: String = "Spawn_"
const MESH_PREFIX: String = "Figure_Mesh_"

const SMOKE_SCENE: String = "res://gdsrc/board/smoke_3d.tscn"
const SMOKE3D_NODE: String = "Smoke3D"
const SMOKE_NODE: String = "SmokeParticles"
const DEPLOYMENT_TIMEOUT = 3
const SMOKE_HEIGHT = 5

const DEPLOYMENT_OFFSET: String = "deploymentZoneOffset"
const DEPLOYMENT_WIDTH: String = "deploymentZoneWidth"

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
var pointer: UltraMekDirectionPointer = null
var smoke_height: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	figure_created = false

func get_spawn_animation_name()->String:
	return SPAWN_ANIMATION_PREFIX + "_" + player.get_player_id() + "_" + unit_id

func get_figure_mesh_name()->String:
	return MESH_PREFIX + "_" + player.get_player_id() + "_" + unit_id

func set_unit_data(data: Dictionary)->void:
	unit_data = data
	
func get_unit_data()->Dictionary:
	return unit_data
	
func get_deployment_data()->Dictionary:
	var data: Dictionary = {}
	data[DEPLOYMENT_OFFSET] = unit_data[DEPLOYMENT_OFFSET]
	data[DEPLOYMENT_WIDTH] = unit_data[DEPLOYMENT_WIDTH]
	return data
	

func deploy(player_name: String, unit_id_name: String, pos: Vector3)->void:
	figure_created = true
	player = Global.players[player_name]
	unit_id = unit_id_name
	pointer = player.get_pointer(unit_id)
	current_pos = pos
	var scene = load(SMOKE_SCENE)
	spawn_animation = scene.instantiate()
	spawn_animation.set_name(get_spawn_animation_name())
	add_child(spawn_animation)
	smoke_height = pos[1]
	pos[1] = smoke_height + SMOKE_HEIGHT
	spawn_animation.set_global_position(pos)
	figure_deployed = true
	
func get_deployment_status()->bool:
	return figure_deployed

func put_figure_on_board(delta: float)->void:
	var figure = Node3D.new()
	if gfx_provided == false:
		figure = _create_dummy(delta)
	add_child(figure)
	figure.set_global_position(current_pos)
	var phi: float = pointer.compute_pointer_rotation_y(pointer.pointer_direction)
	figure.rotate_y(phi)

func _create_dummy(delta: float)->Node3D:
	var dummy = StandeePrimitive.new()
	var color: Color = player.get_player_color()
	var image_data: Dictionary = player.get_player_forces_images()
	var texture_img = image_data[unit_id][Player.IMAGE_2D_KEY]
	dummy.init_standee(texture_img,color)
	dummy.set_name(get_figure_mesh_name())
	return dummy
	
func _import_figure(delta: float):
	pass

func _deploy_time_out(delta: float)->void:
	if figure_created == true:
		var spawn_animation: Node3D = find_child(get_spawn_animation_name(),true,false)
		if timer < DEPLOYMENT_TIMEOUT:
			timer += delta
			var smoke: Node3D = spawn_animation.find_child(SMOKE_NODE,true,false)
			var ratio: float = (DEPLOYMENT_TIMEOUT-timer)/DEPLOYMENT_TIMEOUT
			#smoke.amount_ratio = ratio
			var pos: Vector3 = spawn_animation.get_global_position()
			pos[1] = smoke_height + ratio*SMOKE_HEIGHT
			spawn_animation.set_global_position(pos)
		else:
			timer = 0
			figure_created = false
			put_figure_on_board(delta)
			remove_child(spawn_animation)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.main != null and Global.board != null:
		_deploy_time_out(delta)
		
			
