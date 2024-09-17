extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var standee = StandeePrimitive.new()
	var center = standee.center
	center[2] = center[2] - 0.5
	translate(center)
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
