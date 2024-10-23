extends Button
signal new_game_start(map_name: String,forces: Dictionary,settings: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create_new_game()->void:
	var game_map: String = "test/samples/snow.board"
	var forces: Dictionary  = {"force1":"test/samples/intro1.mul"}
	var settings: Dictionary = {}
	if is_pressed():
		print("Alert: Pressed!!!")
		new_game_start.emit(game_map,forces,settings)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	create_new_game()
