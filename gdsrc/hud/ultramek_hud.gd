class_name UltraMekHud
extends Control

# Time in seconds before a billboard phases out
const TIMEOUT: float = 3

# Node variables
var main_node: Node = null
# Billboard node used for phased-out billboards
var billboard_node: TextureRect = null
# Flag to track if the billboard has been phased out
var billboard_phased_out: bool = false
# Flag to track if the HUD setup is complete
var hud_setup: bool = false

# Timer variable for phased-out animation
var init_timer: float = -1

# Function to create a start screen billboard
func _make_start_screen(container_name: String, billboard_file: String) -> TextureRect:
	# Reset timer on start screen creation
	init_timer = 0
	
	# Find the container node with the specified name
	var container: Node = find_child(container_name, true, false)
	
	# Create a new billboard node
	var billboard: TextureRect = TextureRect.new()
	
	# Load the texture from an external file
	var texture = UltraMekTools.load_texture_from_extern(billboard_file)
	
	# Set the texture on the billboard
	billboard.set_texture(texture)
	
	# Make the billboard stretch mode proportional to its parent's size
	billboard.set_stretch_mode(TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED)
	
	# Add the billboard as a child of the container
	container.add_child(billboard)
	
	# Return the billboard node
	return billboard

# Function to make an HUD node invisible
func _make_hud_invisible(hud_node: Node, msg: String = "invisible") -> void:
	# Check if the HUD node is not null
	if hud_node != null:
		# Hide the HUD node
		hud_node.visible = false
		
		# Log a message if provided
		if msg != "":
			print('Hud Event: ', msg)

# Function to make an HUD node visible
func _make_hud_visible(hud_node: Node, msg: String = "visible") -> void:
	# Check if the HUD node is not null
	if hud_node != null:
		# Show the HUD node
		hud_node.visible = true
		
		# Log a message if provided
		if msg != "":
			print('Hud Event: ', msg)

# Function to animate a billboard phasing out
func _billboard_phase_out(delta: float, container_name: String, 
							hud_node: Node, node_msg: String = "invisible", set_invisible: bool = true) -> void:
	# Check if the animation is still running
	if init_timer >= 0:
		# If not done yet, increment the timer by delta
		if init_timer < TIMEOUT:
			init_timer += delta
		else:
			# Billboard has timed out
			if billboard_node != null:
				# Remove the billboard from its container
				var container: Node = find_child(container_name, true, false)
				container.remove_child(billboard_node)
				
				# Hide the container if phasing out
				if set_invisible == true:
					container.visible = false
				
				# Mark the billboard as phased out
				billboard_phased_out = true
			
			# If the billboard has been phased out and setup is not complete, show it
			if billboard_phased_out == true and hud_setup == false:
				_make_hud_visible(hud_node, node_msg)
				
				# Set setup flag to true
				hud_setup = true
			
			# Reset the timer
			init_timer = -1

# Function to make a node visible when required
func _ready_up_node(node_name: String) -> Node:
	# Find the node with the specified name
	var node: Node = find_child(node_name, true, false)
	
	# If found, show it
	if node != null:
		node.visible = true
	
	# Return the found node
	return node

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	pass  # Replace with function body.

# Called every frame
func _process(delta: float) -> void:
	pass  # Replace with function body.
