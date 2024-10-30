extends Marker3D

const PI: float = atan(1)*4
const CAMERA_NAME: String = "Camera3D"
const WALK_LIGHT_NODE_NAME: String = "WalkLight"
const RAY_LENGTH: float = 17
const DY: float = 2*Board.unit_height

signal change_menu_visibility

var mouse_sense: float = 0.005
var speed: float = 1.0
var rot_speed: float = speed*PI/45
#flags
var ctrl_pressed: bool = false
var menu_hidden: bool = false
var deployment_zone_selected: bool = false
var camera_node: Node
var walk_light_node: Node
var ultra_mek: UltraMekGD = UltraMekGD.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_node = get_node(CAMERA_NAME)
	walk_light_node = find_child(WALK_LIGHT_NODE_NAME,true,false)

func project_cursor(event: InputEvent) -> Vector3:
	var camera = camera_node
	var mouse_pos: Vector2 = event.global_position
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	#var from = camera.get_global_position()
	#var direction = camera.project_ray_origin(mouse_pos)
	var corr: float = 1*Board.unit_height
	var ray_length: float = (corr-from[1])/direction[1] if direction[1] != 0 else RAY_LENGTH
	ray_length = min(ray_length,RAY_LENGTH)
	
	var to = from + direction * ray_length
	return to
	 
func walk_cursor(event) -> void:
	var to = project_cursor(event)
	print("Pos to ",to)
	var grid_centers: Array = Global.ultra_mek_cpp.get_grid_centers()
	if len(grid_centers)>0:
		var to2: Vector2 = Vector2(to[0],to[2])
		var hex: Vector2i = await Global.ultra_mek_cpp.compute_board_hex_for_point(to2)
		var pos: Vector3
		var hex_height: float = (Global.board_data["heights"][hex[0]][hex[1]]+6)*Board.unit_height
		if hex[0]!=-1 and hex[1]!=-1:
			var hex_center: Vector2 = grid_centers[hex[0]][hex[1]]
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		elif hex[0]!=-1 and hex[1]==-1:
			var hex_center: Vector2 = grid_centers[hex[0]][0]
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		elif hex[0]==-1 and hex[1]!=-1:
			var hex_center: Vector2 = grid_centers[0][hex[1]]
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		else:
			pos = to
		walk_light_node.set_global_position(pos)
		print("Pos pos ",pos)

func keyboard_events(event: InputEventKey) -> void:
	if event.get_keycode() == KEY_CTRL:
		#print("Event CTRL: ", event.as_text_key_label(),KEY_CTRL)
		ctrl_pressed = not ctrl_pressed
	elif event.get_keycode() == KEY_A:
		translate(Vector3(-speed,0,0))
	elif event.get_keycode() == KEY_D:
		translate(Vector3(speed,0,0))
	elif event.get_keycode() == KEY_W:
		translate(Vector3(0,0,-speed))
	elif event.get_keycode() == KEY_S:
		translate(Vector3(0,0,speed))
	elif event.get_keycode() == KEY_Q:
		rotate_y(rot_speed)
	elif event.get_keycode() == KEY_E:
		rotate_y(-rot_speed)
	elif event.get_keycode() == KEY_R:
		var rot: Vector3 = get_rotation()
		var valx: float = -PI/2-rot[0]
		var valy: float = 0-rot[1]
		rotate_x(-3*PI/2+valx)
		rotate_y(valy)

func left_click_events(event: InputEvent)->void:
	if Global.game_phase == Global.DEPLOYMENT_PHASE:
		if event.is_pressed():
			if deployment_zone_selected == false:
				deployment_zone_selected = true
			else:
				deployment_zone_selected = false
			

	print("deployment zone selected: ",deployment_zone_selected)

func _input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		if event is InputEventMouseMotion and ctrl_pressed == true:
			rotate_x(event.relative.y*mouse_sense)
			rotate_y(-event.relative.x*mouse_sense)
		elif event is InputEventMouseMotion:
			if deployment_zone_selected == false:
				walk_cursor(event)
		elif event is InputEventMouseButton:
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
				translate(Vector3(0,speed,0))
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
				translate(Vector3(0,-speed,0))
			if event.get_button_index() == MOUSE_BUTTON_LEFT:
				left_click_events(event)
		elif event is InputEventKey:
			keyboard_events(event)
		else:
			pass
			#print("Event: ",event.as_text())
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
