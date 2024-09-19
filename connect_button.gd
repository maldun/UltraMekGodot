extends Button

signal connect_tcp_server
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func connect_server():
	if is_pressed():
		print("Alert: Connect Button pressed")
		connect_tcp_server.emit()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	connect_server()
		
