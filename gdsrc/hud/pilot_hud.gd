class_name PilotHud
extends Button

const HIT_MIN: int = 0
const HIT_MAX: int = 6
const PILOT_HUD_SUFFIX: String = "_PilotHud"
const CONTAINER_SUFFIX: String = "_Container"
const TEXTURE_SUFFIX: String = "_TextureRect"
const LABEL_SUFFIX: String = "_Label"
const PROGRESSBAR_SUFFIX: String = "_ProgressBar"

const GREEN: Color = Color(0,1,0)
const RED: Color = Color(1,0,0)

var portrait: String
var pilots_name: String
var callsign: String

var container: VBoxContainer = null
var container_name: String = ""
	
func set_portrait(pilot_portrait: String)->void:
	portrait = pilot_portrait

# set up the pilot's name (depending if a nick/callsign is available)
func setup_name(pilot_name: String, pilot_nick: String)->String:
	var end_name: String = ""
	if pilot_nick == "":
		# Only use surname when no nick given.
		end_name = pilot_name.split(" ",true)[0]
		name = pilot_name.replace(" ","_").replace("-","_")+PILOT_HUD_SUFFIX
	else:
		end_name = pilot_nick
		name = pilot_nick + PILOT_HUD_SUFFIX
	return end_name
		

# setup the pilothud element consisting of name label, a portrait and a healthbar
func setup_pilot_hud(pilot_name: String, pilot_nick: String, 
					 pilot_wounds: int, pilot_portrait:String)->void:
	
	container = setup_container()
	# Label Setup
	var name_text: String = setup_name(pilot_name,pilot_nick)
	var name_label = setup_label(name_text)
	container.add_child(name_label)
	# Portrait Setup	
	var portrait_rect: TextureRect = setup_portrait(pilot_portrait)
	container.add_child(portrait_rect)
	# Add healthbar
	var health_bar: ProgressBar = setup_health_bar(pilot_wounds)
	container.add_child(health_bar)

# sets up the label for the pilot name
func setup_label(name_text: String)->Label:
	var name_label: Label = Label.new()
	name_label.name = name + LABEL_SUFFIX
	name_label.text = name_text
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return name_label

# sets up the container within the button
func setup_container()->VBoxContainer:
	var vbox = VBoxContainer.new()
	container_name = name + CONTAINER_SUFFIX
	vbox.name = container_name
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.visible = true
	add_child(vbox)
	return vbox

# auxillary function to generate textures for the healthbar
func get_health_bar_texture(rgb: Color)->StyleBoxTexture:
	var sty_tex: StyleBoxTexture = StyleBoxTexture.new()
	var grad: Gradient = Gradient.new()
	# add single color
	grad.add_point(0.0,rgb)
	var tex: GradientTexture1D = GradientTexture1D.new()
	tex.gradient = grad
	sty_tex.texture = tex
	
	return sty_tex
	

# sets up the healthbar using the number of wounds
# each wound adds more red to the bar
func setup_health_bar(wounds: int = 0)->ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.name = name + PROGRESSBAR_SUFFIX
	bar.fill_mode = ProgressBar.FillMode.FILL_BEGIN_TO_END
	bar.min_value = HIT_MIN
	bar.max_value = HIT_MAX - 1
	bar.value = wounds
	bar.background = get_health_bar_texture(GREEN)
	bar.fill = get_health_bar_texture(RED)
	return bar

# creates a texture from the given image file (72x72 is assumed)
func setup_portrait(pilot_portrait: String)->TextureRect:
	set_portrait(pilot_portrait)
	var portrait_texture = UltraMekTools.load_texture_from_extern(pilot_portrait)
	var texr = TextureRect.new()
	texr.texture = portrait_texture
	texr.name = name + TEXTURE_SUFFIX
	return texr
	#icon = portrait_texture
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# a simple test
	
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
