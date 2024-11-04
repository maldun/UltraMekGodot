extends Node

# Keys
const _SETTINGS_KEY: String = "settings"
const _FORCES_KEY: String = "forces"
const _BOARD_KEY: String = "board"

var game_metadata: Dictionary = {}

# Phases
const PREPARATION_PHASE: String = "__PREPARATION__PHASE__"
const DEPLOYMENT_PHASE: String = "__DEPLOYMENT__PHASE__"
const MOVEMENT_PHASE: String = "__MOVEMENT__PAHSE__"
const ATTACK_PHASE: String = "__ATTACK_PHASE__"
const DAMAGE_PHASE: String = "__DAMAGE_PHASE__"

signal processed_board_data(dim_x: int, dim_y: int)

# Directions
enum DIRECTIONS {SE,S,SW,NW,N,NE}

# Important game variables
var game_phase: String = ""
var game_state: Dictionary = {}
var board_data: Dictionary = {}
var ultra_mek_cpp: UltraMekGD = UltraMekGD.new()
var players: Dictionary = {}
var active_player: Player = null

# Geometry
const UNIT_LENGTH: float = 1.0
const UNIT_HEIGTH: float = 0.5

# nodes
var main: Node = null
var game_client: Node = null
var controls: Node = null
var sound: Node = null
var board: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ultra_mek_cpp.set_unit_length(UNIT_LENGTH)
	ultra_mek_cpp.set_unit_height(UNIT_HEIGTH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
