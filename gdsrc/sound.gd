class_name UltraMekSound
extends AudioStreamPlayer

const SOUNDS_MAP_KEY = "sounds_map"
const SOUNDS_DEFAULT_PATH_KEY = "sounds_default_path"

const LANDING = "landing"
const PHASE_START = "phase_start"

var sound_file_map: Dictionary = {}
var sound_map: Dictionary = {}
var sound_default_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var settings: Dictionary = DataHandler.get_json_data(UltraMekMain.SETTING_FILE)
	sound_file_map = DataHandler.get_json_data(settings[SOUNDS_MAP_KEY])
	sound_default_path = settings[SOUNDS_DEFAULT_PATH_KEY]
	_load_sounds(sound_file_map)
	print("sound ready")
	
func _load_sounds(sound_file_map: Dictionary) -> void:
	for key in sound_file_map.keys():
		if FileAccess.file_exists(sound_file_map[key]):
			sound_map[key] = load(sound_file_map[key])
		else:
			sound_map[key] = load(sound_default_path + "/" + sound_file_map[key])

func _play_landing_sound(player_name: String,unit_id: String, pos: Vector3):
	set_stream(sound_map[LANDING])
	play()

func _play_game_phase_start_sound()->void:
	set_stream(sound_map[PHASE_START])
	play()
	
func deployment_sounds(delta: float)->void:
	if Global.main != null:
		Global.main.connect(UltraMekMain.DEPLOY_UNIT_SIGNAL,_play_landing_sound)
		Global.main.connect(UltraMekMain.PLAY_PHASE_START_SOUND_SIGNAL,_play_game_phase_start_sound)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	deployment_sounds(delta)
