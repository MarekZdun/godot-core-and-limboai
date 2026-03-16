extends LimboState

var button_play_menu_clicked: bool = false

@export_file_path("*.tscn") var default_start_scene_filepath: String 


func _enter():
	agent.gui_main_menu = GuiManager.get_gui(GuiManager.add_gui("main_menu", 1, null))
	agent.gui_main_menu.button_play_game_click.connect(_on_button_play_game_clicked)
	
	
func _exit():
	agent.gui_main_menu.button_play_game_click.disconnect(_on_button_play_game_clicked)
	
	
func _update(_p_delta):
	if button_play_menu_clicked:
		button_play_menu_clicked = false
		init_start_scene()
		
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
		elif event.shift_pressed and event.keycode == KEY_L:
			dispatch("to_load_saved_level")
		
		
func init_start_scene() -> void:
	agent.next_scene_id = default_start_scene_filepath	# next_scene_id should be retrieved from the configuration file, and the path should be named default_start_scene_filepath.
	
	var inventory_data := InventoryResource.new()
	inventory_data.add_item("long_sword", 3)
	inventory_data.add_item("short_sword", 1)
	
	var viewport_size: Vector2 = agent.get_viewport().size
	var actor_stats := ActorResource.new()
	actor_stats.current_global_position = viewport_size / 2
	
	GameStateService.new_game()
	GameStateService.set_global_state_value("stats", actor_stats)
	GameStateService.set_global_state_value("trigger_load_actor_global_position_from_game_state", true)
	GameStateService.set_global_state_value("inventory_data", inventory_data)
	dispatch("to_change_level")
	
	
func _on_button_play_game_clicked():
	button_play_menu_clicked = true
