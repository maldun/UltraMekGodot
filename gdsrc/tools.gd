class_name UltraMekTools
extends Node

static func color_up(image_fname: String,player_color: Color)->ImageTexture:
	#var image: Image = Image.new()
	var image = Image.load_from_file(image_fname)
	#image.lock()
	for i in image.get_size().x:
		for j in image.get_size().y:
			var current_pixel = image.get_pixel(i,j)
			if current_pixel.a == 1:
				current_pixel = current_pixel.darkened(0.5)#current_pixel.gray()
				#var new_color = Color.from_hsv(0,0,current_pixel)
				#var new_color = Color(current_pixel,0.5)
				var new_color = current_pixel.blend(player_color)
				image.set_pixel(i,j,new_color)
	#image.unlock()
	var new_texture = ImageTexture.create_from_image(image)
	return new_texture

static func load_texture_from_extern(fname: String)-> ImageTexture:
	var image = Image.load_from_file(fname)
	var texture = ImageTexture.create_from_image(image)
	return texture

static func get_dice_character(nr: int)->String:
	if nr == 1:
		return '⚀'
	elif nr == 2:
		return '⚁'
	elif nr == 3:
		return '⚂'
	elif nr == 4:
		return '⚃'
	elif nr == 5:
		return '⚄'
	elif nr == 6:
		return '⚅'
	else:
		return ''

static func unique(array: Array)->Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

const MECHASIDE_FONT: String = "res://assets/fonts/mechaside/Mechaside-Regular.ttf"
const MECHASIDE_ITALIC_FONT: String = "res://assets/fonts/mechaside/Mechaside-Italic.ttf"

static func setup_mechaside_label(text: String, size: int, italic: bool = false)-> Label:
	var mechaside_font: FontFile
	if italic:
		mechaside_font = preload(MECHASIDE_ITALIC_FONT)
	else:
		mechaside_font = preload(MECHASIDE_FONT)
	
	var label: Label = Label.new()
	label.add_theme_font_override("font",mechaside_font)
	label.add_theme_font_size_override("font_size",size)
	return label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
