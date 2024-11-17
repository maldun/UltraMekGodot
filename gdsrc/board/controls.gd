class_name UltraMekControls
extends Marker3D

const PI: float = atan(1)*4
const CAMERA_NAME: String = "Camera3D"
const WALK_LIGHT_NODE_NAME: String = "WalkLight"
const RAY_LENGTH: float = 17
const DY: float = 2*Board.unit_height
const DT: float = 1/60

signal change_menu_visibility
const ROTATE_DEPL_POINTER_SIGNAL = "rotate_deployment_pointer_signal"
signal rotate_deployment_pointer_signal(player_name: String, unit_id: String, pos: Vector3, mouse_pos:Vector2)
const REMOVE_POINTER_SIGNAL: String = "remove_pointer_signal"
signal remove_pointer_signal(player_name: String, unit_id: String)
const DEPLOY_UNIT_SIGNAL = "deploy_unit"
signal deploy_unit(player_name: String,unit_id: String,pos: Vector3)

var mouse_sense: float = 0.005
var speed: float = 1.0
var rot_speed: float = speed*PI/45
var current_time: float = 0
const RESET_INTERVAL: float = 1000
var delays: Dictionary = {}
# flags
var ctrl_pressed: bool = false
var left_mouse_pressed: bool = false
var menu_hidden: bool = false
var deployment_zone_selected: bool = false
var deployment_dir_selected: bool = false
var dbutton_pressed: bool = false
var in_grid: bool = false

var current_player: String
var current_unit: String

var cursor_map_position: Vector3 = Vector3(0,0,0)
var cursor_mouse_position: Vector2 = Vector2(0,0)
var cursor_grid_position: Vector2i = Vector2i(-1,-1)

# nodes
var camera_node: Node
var walk_light_node: Node
var deployment_hud_node: Node = null
var ultra_mek: UltraMekGD = UltraMekGD.new()

# light colors
const DEFAULT_COLOR: Color = Color(0.17,0.26,0.56)
const BLOCKED_COLOR: Color = Color(1.0,0.0,0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_node = get_node(CAMERA_NAME)
	walk_light_node = find_child(WALK_LIGHT_NODE_NAME,true,false)
	Global.controls = self

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
	var grid_centers: Array = Global.ultra_mek_cpp.get_grid_centers()
	if len(grid_centers)>0:
		var to2: Vector2 = Vector2(to[0],to[2])
		var hex: Vector2i = await Global.ultra_mek_cpp.compute_board_hex_for_point(to2)
		var pos: Vector3
		var hex_height: float = (Global.board_data["heights"][hex[0]][hex[1]]+6)*Board.unit_height
		cursor_grid_position = Vector2i(hex)
		if hex[0]!=-1 and hex[1]!=-1:
			var hex_center: Vector2 = grid_centers[hex[0]][hex[1]]
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		elif hex[0]!=-1 and hex[1]==-1:
			var hex_center: Vector2 = grid_centers[hex[0]][0]
			cursor_grid_position[1] = 0
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		elif hex[0]==-1 and hex[1]!=-1:
			var hex_center: Vector2 = grid_centers[0][hex[1]]
			cursor_grid_position[0] = 0
			pos = Vector3(hex_center[0],hex_height+DY,hex_center[1])
		else:
			cursor_grid_position[0] = 0
			cursor_grid_position[1] = 0
			pos = to
		walk_light_node.set_global_position(pos)
		cursor_map_position = pos

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
	if event.is_pressed():
		left_mouse_pressed = true
	else:
		left_mouse_pressed = false
		
	if Global.game_phase == Global.DEPLOYMENT_PHASE:
		deployment_hud_control(event)

func _deployment_confirmed_button(player_name: String, unit_id: String):
	deployment_zone_selected = false

func color_cursor()->void:
	in_grid = deployment_hud_node.check_deployment_zone(current_player,current_unit,cursor_grid_position)
	if in_grid == false:
		walk_light_node.light_color = BLOCKED_COLOR
	else:
		walk_light_node.light_color = DEFAULT_COLOR

func deployment_hud_control(event: InputEvent) -> void:
	if deployment_hud_node != null:
		var fun: Callable = func _check_deployment_button_press(player_name: String,
								 entity_id: String)->void:
				dbutton_pressed = true
				current_player = player_name
				current_unit = entity_id
	
		await deployment_hud_node.connect(
			DeploymentHud.DEPLOYMENT_BUTTON_PRESSED_SIGNAL,
			fun 
			)
	
	if dbutton_pressed == true and in_grid == true:
		if deployment_zone_selected == false and deployment_dir_selected == false and event.is_pressed():			
			deployment_zone_selected = true
			cursor_mouse_position = event.global_position
		elif deployment_zone_selected==true and deployment_dir_selected==true and not event.is_pressed():
			dbutton_pressed = false
			deployment_dir_selected = false
			deployment_zone_selected = false
			deploy_unit.emit(current_player,current_unit,cursor_map_position)
		else:
			deployment_zone_selected = false
			deployment_dir_selected = false
			
	if deployment_hud_node != null and (not deployment_hud_node.is_connected(
			DeploymentHud.DEPLOYMENT_UNIT_CONFIRMED_SIGNAL,_deployment_confirmed_button)):
		deployment_hud_node.connect(DeploymentHud.DEPLOYMENT_UNIT_CONFIRMED_SIGNAL,
								_deployment_confirmed_button
	)

func deployment_hud_control_mouse_motion(event: InputEvent)->void:
	if deployment_zone_selected == false:
		walk_cursor(event)
		if dbutton_pressed == true:
			color_cursor()
		
	if (left_mouse_pressed == true and deployment_zone_selected == true
	 and dbutton_pressed == true):
		deployment_dir_selected=true
		var rel_position = event.global_position - cursor_mouse_position
		rotate_deployment_pointer_signal.emit(current_player,current_unit,cursor_map_position,rel_position)

func _mouse_motion_events(event: InputEventMouseMotion)-> void:
	if Global.game_phase == Global.DEPLOYMENT_PHASE:
		deployment_hud_control_mouse_motion(event)

func _deployment_hud_control_right_click(event: InputEventMouseButton):
	if event.is_pressed() and dbutton_pressed == true:
		deployment_dir_selected = false
		deployment_zone_selected = false
		left_mouse_pressed = false
		dbutton_pressed = false
		remove_pointer_signal.emit(current_player,current_unit)

func _right_click_events(event: InputEventMouseButton):
	if Global.game_phase == Global.DEPLOYMENT_PHASE:
		_deployment_hud_control_right_click(event)
func _input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		if event is InputEventMouseMotion and ctrl_pressed == true:
			rotate_x(event.relative.y*mouse_sense)
			rotate_y(-event.relative.x*mouse_sense)
		elif event is InputEventMouseMotion:
			_mouse_motion_events(event)
		elif event is InputEventMouseButton:
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
				translate(Vector3(0,speed,0))
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
				translate(Vector3(0,-speed,0))
			if event.get_button_index() == MOUSE_BUTTON_LEFT:
				left_click_events(event)
			if event.get_button_index() == MOUSE_BUTTON_RIGHT:
				_right_click_events(event)
		elif event is InputEventKey:
			keyboard_events(event)
		else:
			pass
			#print("Event: ",event.as_text())

func get_node_from_main(name: String)-> Node:
	if Global.main != null:
		var node: Node = Global.main.find_child(name,true,false)
		return node
	else:
		return null
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func retrieve_nodes() -> void:
	deployment_hud_node = get_node_from_main(UltraMekMain.DEPLOYMENT_HUD_NAME)
		
func _process(delta: float) -> void:
	if current_time < RESET_INTERVAL:
		current_time += delta
	else:
		current_time = 0
	retrieve_nodes()
