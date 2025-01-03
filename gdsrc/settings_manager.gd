class_name SettingsManager
extends Node

var game_settings: Dictionary = {}
var settings: Dictionary = {}

const GAME_SETTING_KEY: String = "game_settings"
const SESSION_TYPE_KEY: String = "session_type"
const PLAYERS_KEY: String = "players"
const HOST_PLAYER_KEY: String = "host_player"
const RULES_KEY: String = "rules"
const RULESET_KEY: String = "ruleset"
const SUPPORTED_RULESETS: Array[String] = ["quickstart_rules"]


const HOT_SEAT_SESSION: String =  "hot_seat"
const NETWORK_SESSION: String = "network"

const ERR_TITLE_MISSING_SETTING: String = "Missing Settings!"
const ERR_TITLE_WRONG_SETTING: String = "Wrong Settings!"
const ERR_MSG_MISSING_PLAYERS: String = "Players not provided in Game Setting!"
const ERR_MSG_MISSING_HOST_PLAYER: String = "No Host player defined!"
const ERR_MSG_MISSING_GAME_SETTINGS: String = "Game Settings not provided!"
const ERR_MSG_MISSING_SESSION_TYPE: String = "No Session in Settings!"
const ERR_MSG_WRONG_HOST_PLAYER: String = "Host Player not found!"
const ERR_MSG_MISSING_RULES: String = "Rules not defined or missing!"
const ERR_MSG_MISSING_RULESET: String = "Ruleset missing!"
const ERR_MSG_WRONG_RULESET: String = "Ruleset not supported!"

func set_settings(setting_dict: Dictionary, game_setting_dict:Dictionary) -> void:
	game_settings = game_setting_dict
	settings = setting_dict

func get_session_type()-> String:
	if not (GAME_SETTING_KEY in game_settings.keys()):
		OS.alert(ERR_MSG_MISSING_GAME_SETTINGS,ERR_TITLE_MISSING_SETTING)
	if not (SESSION_TYPE_KEY in game_settings[GAME_SETTING_KEY].keys()):
		OS.alert(ERR_MSG_MISSING_SESSION_TYPE,ERR_TITLE_MISSING_SETTING)
	return game_settings[GAME_SETTING_KEY][SESSION_TYPE_KEY]
	
func get_session_player_number()-> int:
	if not (PLAYERS_KEY in game_settings.keys()):
		OS.alert(ERR_MSG_MISSING_PLAYERS,ERR_MSG_MISSING_GAME_SETTINGS)
	return len(game_settings[PLAYERS_KEY])
	
func get_host_player()->String:
	if not(HOST_PLAYER_KEY in game_settings.keys()):
		OS.alert(ERR_MSG_MISSING_HOST_PLAYER,ERR_TITLE_MISSING_SETTING)
	var host_player: String = game_settings[HOST_PLAYER_KEY]
	if not(PLAYERS_KEY in game_settings.keys()):
		OS.alert(ERR_MSG_MISSING_PLAYERS,ERR_TITLE_MISSING_SETTING)
	if not(host_player in game_settings[PLAYERS_KEY].keys()):
		OS.alert(ERR_MSG_WRONG_HOST_PLAYER,ERR_TITLE_WRONG_SETTING)
	return host_player
	
func get_ruleset()->String:
	if not(RULES_KEY in game_settings.keys()):
		OS.alert(ERR_MSG_MISSING_RULES,ERR_TITLE_MISSING_SETTING)
	var rules: Dictionary = game_settings[RULES_KEY]
	if not (RULESET_KEY in rules.keys()):
		OS.alert(ERR_MSG_MISSING_RULESET,ERR_TITLE_MISSING_SETTING)
	var ruleset: String = rules[RULESET_KEY]
	if ruleset not in SUPPORTED_RULESETS:
		OS.alert(ERR_MSG_WRONG_RULESET,ERR_TITLE_WRONG_SETTING)
	return ruleset

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
