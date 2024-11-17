extends Node

# Keys
const SETTINGS_KEY: String = "settings"
const FORCES_KEY: String = "forces"
const BOARD_KEY: String = "board"
const PLAYER_KEY: String = "player"

const INITIATIVE_ROLLED_KEY: String = "initiative_rolled"
const PLAYER_ORDER_KEY: String = "player_order"

var game_metadata: Dictionary = {}

# Phases
const PREPARATION_PHASE: String = "__PREPARATION__PHASE__"
const INITIATIVE_PHASE: String = "__INITIATIVE__PHASE__"
const DEPLOYMENT_PHASE: String = "__DEPLOYMENT__PHASE__"
const MOVEMENT_PHASE: String = "__MOVEMENT__PHASE__"
const ATTACK_PHASE: String = "__ATTACK__PHASE__"
const DAMAGE_PHASE: String = "__DAMAGE__PHASE__"

signal processed_board_data(dim_x: int, dim_y: int)

# round counter
var round_nr: int = -1

# Directions
enum DIRECTIONS {SE,S,SW,NW,N,NE}

# Important game variables
var game_phase: String = ""
var game_state: Dictionary = {}
var board_data: Dictionary = {}
var ultra_mek_cpp: UltraMekGD = UltraMekGD.new()
var players: Dictionary = {}
var active_player: Player = null
var session_players: Array[String] = []
var player_order: Array[String] = []

# Geometry
const UNIT_LENGTH: float = 1.0
const UNIT_HEIGTH: float = 0.5

# nodes
var main: Node = null
var game_client: Node = null
var controls: Node = null
var sound: Node = null
var board: Node = null
var settings: SettingsManager = SettingsManager.new()

const mecha_font: FontFile = preload("res://assets/fonts/mechaside/Mechaside-Regular.ttf")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ultra_mek_cpp.set_unit_length(UNIT_LENGTH)
	ultra_mek_cpp.set_unit_height(UNIT_HEIGTH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func next_player()->void:
	var active_name: String = active_player.get_player_id()
	var order: Array[String] = []
	# before initiative assume all are equal ...
	if len(player_order) == 0:
		for p in Global.players.keys():
			order.append(p)
	else:
		order = player_order
		
	var lp: int = len(order)
	active_player = null
	for k in range(lp):
		if order[k] == active_name:
			var ind: int = (k+1)%lp
			active_player = players[order[ind]]
			break
	
