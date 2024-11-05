class_name Player
extends Node

const FORCES_KEY: String = "forces"
const ENTITIES_KEY: String = "entities"
const CHASSIS_KEY: String = "chassis"
const MODEL_KEY: String = "model"
const GFX_DATA_KEY: String = "gfx_data"
const IMAGE_2D_KEY: String = "gfx_2d_image"
const COLOR_KEY: String = "color"
const DEFAULT_ALPHA: float = 0.5
const PLAYER_PREFFIX: String = "Player_"

var player_data: Dictionary = {}
var forces_gfx_data: Dictionary = {}
var figures: Dictionary = {}
var player_name: String = ""
var player_color: Color
var pointers: Dictionary = {}

func setup_player(name: String, data: Dictionary):
	player_name = name
	player_data = data
	
	# get color
	player_color = get_player_color(DEFAULT_ALPHA)
	
	# store gfx data for later access
	var forces: Dictionary = get_player_forces()
	for member in forces.keys():
		var member_data = forces[member]
		var gfx_data_file: String = member_data[GFX_DATA_KEY]
		var gfx_data: Dictionary = DataHandler.get_json_data(gfx_data_file)
		forces_gfx_data[member] = gfx_data

func get_figure_id(unit_id: String)->String:
	return PLAYER_PREFFIX + player_name+'_'+unit_id

func add_figure(unit_id: String)->Node:
	var fig: UltraMekUnit = UltraMekUnit.new()
	fig.set_name(get_figure_id(unit_id))
	figures[unit_id] = fig
	return fig
	
func add_pointer(unit_id: String)->UltraMekDirectionPointer:
	var pointer : UltraMekDirectionPointer = UltraMekDirectionPointer.new()
	var pointer_name: String = pointer.get_pointer_name(player_name,unit_id)
	pointer.set_name(pointer_name)
	pointers[unit_id] = pointer
	return pointer

func pointer_exists(unit_id: String)-> bool:
	return unit_id in pointers.keys()

func get_pointer(unit_id: String)->UltraMekDirectionPointer:
	if pointer_exists(unit_id):
		return pointers[unit_id]
	else:
		return null

func get_player_name()->String:
	return player_name
	
func get_player_forces()->Dictionary:
	return player_data[FORCES_KEY][ENTITIES_KEY]

func get_player_color(alpha:float = DEFAULT_ALPHA)->Color:
	var color_data: Array = player_data[COLOR_KEY]
	var color: Color = Color(color_data[0],color_data[1],color_data[2],alpha)
	return color

func get_player_forces_images()->Dictionary:
	var forces: Dictionary = get_player_forces()
	var pictures: Dictionary = {}
	for member in forces.keys():
		var picture_data = {}
		var member_data = forces[member]
		picture_data[CHASSIS_KEY]=member_data[CHASSIS_KEY]
		picture_data[MODEL_KEY]=member_data[MODEL_KEY]
		picture_data[IMAGE_2D_KEY] = forces_gfx_data[member][IMAGE_2D_KEY]
		pictures[member] = picture_data
		
	return pictures
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
