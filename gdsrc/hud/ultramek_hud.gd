class_name UltraMekHud
extends Control

const TIMEOUT: float = 3

var main_node: Node = null
var billboard_node: TextureRect = null
var billboard_phased_out: bool = false
var hud_setup: bool = false

var init_timer: float = -1

func _make_start_screen(container_name: String,billboard_file: String)->TextureRect:
	init_timer = 0
	var container: Node = find_child(container_name,true,false)
	var billboard: TextureRect = TextureRect.new()
	var texture = UltraMekTools.load_texture_from_extern(billboard_file)
	billboard.set_texture(texture)
	#billboard.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	billboard.set_stretch_mode(TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED)
	container.add_child(billboard)
	return billboard

func _make_hud_invisible(hud_node:Node,msg: String="invisible") -> void:
	if hud_node != null:
		hud_node.visible = false
		if msg != "":
			print('Hud Event: ',msg)
		
func _make_hud_visible(hud_node:Node,msg: String="visible") -> void:
	if hud_node != null:
		hud_node.visible = true
		if msg != "":
			print('Hud Event: ',msg)

func _billboard_phase_out(delta: float,container_name: String, 
						  hud_node: Node,node_msg: String,set_invisible:bool =true)->void:
	if init_timer >= 0:
		if init_timer < TIMEOUT:
			init_timer += delta
		else:
			if billboard_node != null:
				var container: Node = find_child(container_name,true,false)
				container.remove_child(billboard_node)
				if set_invisible == true:
					container.visible = false
				billboard_phased_out=true
			if billboard_phased_out==true and hud_setup==false:
				_make_hud_visible(hud_node,node_msg)
				hud_setup = true
			init_timer = -1
			

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
