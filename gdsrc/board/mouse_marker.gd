extends Marker3D

const WALK_LIGHT_NODE_NAME: String = "WalkLight"

var mouse_sense: float = 0.005

var walk_light_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walk_light_node = find_child(WALK_LIGHT_NODE_NAME,true,false)
	print("Light Pos: ",walk_light_node.get_global_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta*2
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		if event is InputEventMouseMotion:
			#rotate_x(event.relative.y*mouse_sense)
			#rotate_y(-event.relative.x*mouse_sense)
			var mouse_pos: Vector2 = event.global_position
			#var light_pos: Vector3 = Vector3(-5,17,-8)
			var light_pos: Vector3 = Vector3(mouse_pos[0]/100,17,mouse_pos[1]/100)
			walk_light_node.set_global_position(light_pos)
			print("Light Pos: ",light_pos)
