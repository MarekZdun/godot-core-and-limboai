extends LimboState

var exit_level: bool = false
var go_to_next_level: bool = false


func _enter():
	SceneManager.current_scene.exit_level.connect(_on_exit_level)
	SceneManager.current_scene.change_level.connect(_on_change_to_next_level)
	
	
func _exit():
	SceneManager.current_scene.exit_level.disconnect(_on_exit_level)
	SceneManager.current_scene.change_level.disconnect(_on_change_to_next_level)
	
	
func _update(_p_delta):
	if exit_level:
		exit_level = false
		SceneManager.change_scene("")
		GuiManager.destroy_gui(agent.gui_hud.id, null)
		dispatch("to_main_menu")
		
	if go_to_next_level:
		go_to_next_level = false
		dispatch("to_change_level")
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.shift_pressed and event.keycode == KEY_S:
			agent.save_game()
			
		elif event.shift_pressed and event.keycode == KEY_L:
			dispatch("to_load_saved_level")
			
			
func _on_exit_level():
	exit_level = true
			
			
func _on_change_to_next_level(next_scene_filepath: String):
	agent.next_scene_id = next_scene_filepath
	go_to_next_level = true
