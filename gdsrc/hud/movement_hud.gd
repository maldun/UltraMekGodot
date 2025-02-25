class_name MovementHud
extends UltraMekHud

const PORTRAIT_CONTAINER: String = "PortraitContainer"
const MAIN_CONTAINER_NAME: String = "CenterContainer"
const MOVE_BILLBOARD: String = "res://assets/menu/movement_phase_billboard.png"

var button_container_node: HBoxContainer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	current_phase = Global.game_phase
	billboard_node = _make_start_screen(MAIN_CONTAINER_NAME,MOVE_BILLBOARD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_billboard_phase_out(delta,MAIN_CONTAINER_NAME,null,"invisible",false)
