extends Node

const DEPLOYMENT_PHASE: String = "__DEPLOYMENT__PHASE__"
const MOVEMENT_PHASE: String = "__MOVEMENT__PAHSE__"
const ATTACK_PHASE: String = "__ATTACK_PHASE__"
const DAMAGE_PHASE: String = "__DAMAGE_PHASE__"

signal processed_board_data(dim_x: int, dim_y: int)

var game_state: Dictionary = {}
var board_data: Dictionary = {}
var ultra_mek_cpp: UltraMekGD = UltraMekGD.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
