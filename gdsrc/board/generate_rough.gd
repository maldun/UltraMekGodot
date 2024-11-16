class_name Rough
extends Node3D

const NR_STONES_LIGHT: int = 3
const NR_STONES_HEAVY: int = 6
const PI: float = atan(1)*4

const rock1_snow = preload("res://assets/hexes/scenes/rock_1_snow.tscn")
const rock2_snow = preload("res://assets/hexes/scenes/rock_2_snow.tscn")

const rock_map = {"snow": {0:rock1_snow,
						   1:rock2_snow
						}
				}

static func generate(ttype: String, hex: Hex, is_light:bool = true):
	var nr_trees: int = NR_STONES_LIGHT if is_light == true else NR_STONES_HEAVY
	#var center: Vector2 = hex.hex_center
	#var height: float = hex.hex_height
	var unit_length: float = hex.unit_length
	#var radius: float = unit_length*0.9
	var rng = RandomNumberGenerator.new()
	var nr_stone_types = len(rock_map[ttype])
	var scenes = []
	for k in range(nr_trees):
		var stone = rock_map[ttype][rng.randi_range(0,nr_stone_types-1)]
		var tstone = stone.instantiate()
		tstone.name = hex.name + "_Stone" + str(k)
		scenes.append(tstone)
	return scenes
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
