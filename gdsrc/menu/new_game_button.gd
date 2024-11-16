extends Button
signal new_game_start(map_name: String,players: Dictionary,settings: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create_new_game()->void:
	var main_node: Node = Global.main
	if main_node != null and len(main_node.game_settings)>0:
		if is_pressed():
			#print("Game Settings: ",main_node.game_settings)
			var game_map: String = main_node.game_settings[UltraMekMain.BOARD_KEY]
			#var game_map: String = "test/samples/snow.board"
			var players: Dictionary = main_node.game_settings[UltraMekMain.PLAYERS_KEY] #{"player1":{"board":"test/samples/intro1.mul"}}
			var settings: Dictionary = main_node.game_settings[UltraMekMain.GAME_SETTINGS_KEY]
			print("Alert: Pressed!!!")
			new_game_start.emit(game_map,players,settings)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	create_new_game()
