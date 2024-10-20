class_name Forest
extends Node3D

const NR_TREES_LIGHT: int = 3
const NR_TREES_HEAVY: int = 6
const PI: float = atan(1)*4

# preload of scenes for tree generation
const low_poly_autumn_tree = preload("res://assets/hexes/scenes/low_poly_tree_autumn.tscn")
const dry_tree = preload("res://assets/hexes/scenes/dry_tree.tscn")
const fir = preload("res://assets/hexes/scenes/fir2.tscn")

const tree_map = {"snow": {0:low_poly_autumn_tree,
						   1:dry_tree,
						   2:fir
						}
				}

static func generate(ttype: String, hex: Hex, is_light:bool = true)-> Array:
	var nr_trees: int = NR_TREES_LIGHT if is_light == true else NR_TREES_HEAVY
	var rng = RandomNumberGenerator.new()
	var nr_tree_types = len(tree_map[ttype])
	var scenes: Array = []
	for k in range(nr_trees):
		var nr: int = rng.randi_range(0,nr_tree_types-1)
		var tree: PackedScene = await tree_map[ttype][nr]
		var tscene = await tree.instantiate()
		tscene.name = hex.name + "_Tree" + str(k)
		scenes.append(tscene)
	
	return scenes
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
