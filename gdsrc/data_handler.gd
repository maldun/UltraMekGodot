class_name DataHandler
extends Node

static func get_json_data(fname: String) -> Dictionary:
	var file = FileAccess.open(fname,FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var json_status = json.parse(text)
	var data = json.data
	return data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
