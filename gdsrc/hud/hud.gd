extends Control

const DEPLOYMENT_HUD_NODE: String = "CanvasLayer/DeploymentHud"

var preparation_hud: Node
var deployment_hud: Node

var current_phase: String

var main_node: Node = null

func _ready_up_node(name: String) -> Node:
	var node: Node = get_node(name)
	node.visible = false
	return node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	deployment_hud = _ready_up_node(DEPLOYMENT_HUD_NODE)
	current_phase = Global.game_phase
		
func _make_hud_invisible(hud_node:Node,msg: String="invisible") -> void:
	if hud_node != null:
		hud_node.visible = false
		if msg != "":
			print('Hud Event: ',msg)
		
func _make_hud_visible(hud_node:Node,msg: String="visible") -> void:
	if hud_node != null:
		hud_node.visible = true
		if msg != "":
			print('Hud Event: ',msg)
		
func _reset_hud() -> void:
	_make_hud_invisible(deployment_hud)

func _check_phase(delta: float):
	if current_phase != Global.game_phase:
		current_phase = Global.game_phase
		_reset_hud()
		
		if Global.game_phase == Global.PREPARATION_PHASE:
			pass
		if Global.game_phase == Global.DEPLOYMENT_PHASE:
			_make_hud_visible(deployment_hud,"Deployment Hud visible!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_phase(delta)
	pass
