class_name UltraMekUnit
extends Node3D

const SPAWN_ANIMATION_PREFIX: String = "Spawn_"
const MESH_PREFIX: String = "Figure_Mesh_"
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	figure_created = false

func get_spawn_animation_name()->String:
	return SPAWN_ANIMATION_PREFIX + "_" + player.get_player_name() + "_" + unit_id

func get_figure_mesh_name()->String:
	return MESH_PREFIX + "_" + player.get_player_name() + "_" + unit_id

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
	

func put_figure_on_board(delta: float)->void:
	if gfx_provided == false:
		var dummy = _create_dummy(delta)
		add_child(dummy)
		dummy.set_global_position(current_pos)
	

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
		
			
