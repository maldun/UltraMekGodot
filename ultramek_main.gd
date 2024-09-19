extends Node
signal connect_tcp_server_main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tcp_server_connect()
	_setup_game()

func _tcp_server_connect():
	print("Alert: Main Menu Server Connect")
	connect_tcp_server_main.emit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cb = find_child("ConnectButton",true,false)
	cb.connect("connect_tcp_server",_tcp_server_connect)

func _setup_game():
	_set_mouse()

func _set_mouse():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Load the custom images for the mouse cursor.
	#var arrow = load("res://arrow.png")
	#var beam = load("res://beam.png")
	#Input.set_custom_mouse_cursor(arrow)
	#Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
