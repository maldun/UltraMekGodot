extends Button
signal new_game_start(map_name: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create_new_game()->void:
	var game_map: String = "test/samples/snow.board"
	if is_pressed():
		new_game_start.emit(game_map)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	create_new_game()
