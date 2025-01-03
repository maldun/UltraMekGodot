class_name MovementHud
extends UltraMekHud

const PORTRAIT_CONTAINER: String = "PortraitContainer"

var button_container_node: HBoxContainer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
