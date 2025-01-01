class_name InitiativeHud
extends UltraMekHud

const CONTAINER_NAME: String = "CenterContainer"
const INIT_BILLBOARD: String = "res://assets/menu/initiative_phase_billboard.png"
const INIT_BUTTON_NAME: String = "InitiativeButton"

var init_button: Button = null
var init_button_set: bool = false
var current_phase: String = ""
var show_initiative = false
var show_result: bool = false
var finish_up: bool = false

const INIT_BUTTON_PRESSED_SIGNAL: String = "init_button_pressed_signal"
signal init_button_pressed_signal(player_name: String)

const INIT_BUTTON_PRESSED2_SIGNAL: String = "init_button_pressed2_signal"
signal init_button_pressed2_signal()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_parent()
	current_phase = Global.game_phase
	billboard_node = _make_start_screen(CONTAINER_NAME,INIT_BILLBOARD)
	_set_initiative_button()


func _set_initiative_button()->void:
	if init_button_set == false:
		var container: Node = find_child(CONTAINER_NAME,true,false)
		if init_button != null:
			container.remove_child(init_button)
			init_button.queue_free()
		
		init_button = Button.new()
		var text: String = Global.active_player.get_player_name()
		init_button.text = text
		init_button.add_theme_font_override("font",Global.mecha_font)
		init_button.add_theme_font_size_override("font_size", 72)
		#init_button.icon = (load(DEPLOYMENT_LOGO))
		init_button.set_name(INIT_BUTTON_NAME)
		init_button.disabled = true
		init_button.visible = false
		container.add_child(init_button)
		init_button_set = true

func _init_button_click()->void:
	if init_button != null:
		if init_button.is_pressed():
			var player_id: String = Global.active_player.get_player_id()
			if show_initiative == false:
				if show_result == false:
					init_button_pressed_signal.emit(player_id)
				else:
					if finish_up == false:
						show_initiative = false
						init_button_set = false
						_set_initiative_button()
						init_button.visible = true
						init_button.disabled = false
						show_result_button(Global.player_order)
					else:
						init_button_pressed2_signal.emit()
					
			else:
				if len(Global.player_order)>0:
					if show_result == true:
						if finish_up == true:
							init_button_pressed2_signal.emit()
					else:
						show_result = true
						init_button_set = false
						show_initiative = false
				else:
					Global.next_player()
					show_initiative = false
					init_button_set = false
					_set_initiative_button()
					init_button.visible = true
					init_button.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_billboard_phased_out(delta)
	_init_button_process()

#func _billboard_phase_out(delta: float)->void:
	#if init_timer >= 0:
		#if init_timer < TIMEOUT:
			#init_timer += delta
		#else:
			#if billboard_node != null:
				#var container: Node = find_child(CONTAINER_NAME,true,false)
				#container.remove_child(billboard_node)
				##container.visible = false
				#billboard_phased_out=true
			#if billboard_phased_out==true and hud_setup==false:
				#hud_setup = true
			#if init_button_set == true:
				#init_button.visible = true
				#init_button.disabled = false
			#init_timer = -1

func _billboard_phased_out(delta: float)->void:
	_billboard_phase_out(delta,CONTAINER_NAME,null,"",false)
	if init_timer >= 0:
		if init_timer >= TIMEOUT:
			if init_button_set == true:
				init_button.visible = true
				init_button.disabled = false
			

func _init_button_process()->void:
	_init_button_click()

func show_result_button(player_order: Array[String]) -> void:
	#init_button.disabled = true
	var result_text: String = "Initiative Order:\n"
	for player in player_order:
		result_text += Global.players[player].get_player_name() + '\n'
		init_button.text = result_text
	#show_initiative = true
	finish_up = true
	
func show_initiative_button(player_name: String, initiative: int, dices: Array) -> void:
	#init_button.disabled = true
	if show_result == false:
		var text: String = player_name + '\n'
		text += "Rolled: " + str(initiative) + '\n'
		text += UltraMekTools.get_dice_character(dices[0]) 
		text += " " + UltraMekTools.get_dice_character(dices[1]) + '\n'
		init_button.text = text
		show_initiative = true

func show_reroll_button()->void:
	if show_result == false:
		init_button.text = "Same Result!\nRe-Roll!"
