extends LimboState

var gui_progress_loaded: bool = false

@export var transition_config_fade_in_001: TransitionConfigFadeResource


func _enter():
	var gui_progress_id: String = GuiManager.add_gui_above_top_one("progress", transition_config_fade_in_001)
	get_root().gui_progress = GuiManager.get_gui(gui_progress_id)
	GuiManager.manager_gui_loaded.connect(_on_gui_on_screen)
	
	
func _exit():
	GuiManager.manager_gui_loaded.disconnect(_on_gui_on_screen)
	
	
func _update(_p_delta):
	if gui_progress_loaded:
		gui_progress_loaded = false
		dispatch("to_load_saved_level")


func _on_gui_on_screen(gui):
	if gui.id == get_root().gui_progress.id:
		gui_progress_loaded = true
