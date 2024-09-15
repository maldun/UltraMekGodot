extends Marker3D

const PI: float = atan(1)*4

var mouse_sense: float = 0.005
var speed: float = 1.0
var rot_speed: float = speed*PI/45
var ctrl_pressed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		if event is InputEventMouseMotion and ctrl_pressed == true:
			rotate_x(event.relative.y*mouse_sense)
			rotate_y(-event.relative.x*mouse_sense)
		elif event is InputEventMouseButton:
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
				translate(Vector3(0,speed,0))
			if event.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
				translate(Vector3(0,-speed,0))
		elif event is InputEventKey:
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
		else:
			pass
			#print("Event: ",event.as_text())
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
