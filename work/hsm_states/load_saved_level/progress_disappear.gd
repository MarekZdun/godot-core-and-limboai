extends LimboState

var gui_progress_unloaded: bool = false

@export var transition_config_fade_out_001: TransitionConfigFadeResource


func _enter():
	GuiManager.destroy_gui(agent.gui_progress.id, transition_config_fade_out_001)
	GuiManager.manager_gui_unloaded.connect(_on_gui_off_screen)
	
	
func _exit():
	GuiManager.manager_gui_unloaded.disconnect(_on_gui_off_screen)
	
	
func _update(_p_delta):
	if gui_progress_unloaded:
		gui_progress_unloaded = false
		dispatch("to_curtain_disappear")
	
	
func _on_gui_off_screen(gui_id):
	if gui_id == agent.gui_progress.id:
		gui_progress_unloaded = true
