extends LimboState

var gui_curtain_loaded: bool = false

@export var transition_config_fade_in_001: TransitionConfigFadeResource


func _enter():
	var gui_curtain_id: String = GuiManager.add_gui("curtain", 1, transition_config_fade_in_001)
	agent.gui_curtain = GuiManager.get_gui(gui_curtain_id)
	GuiManager.manager_gui_loaded.connect(_on_gui_on_screen)
	
	
func _exit():
	GuiManager.manager_gui_loaded.disconnect(_on_gui_on_screen)
	if is_instance_valid(agent.gui_main_menu):
		GuiManager.destroy_gui(agent.gui_main_menu.id, null)
	
	
func _update(_p_delta):
	if gui_curtain_loaded:
		gui_curtain_loaded = false
		dispatch("to_progress_appear")
	
	
func _on_gui_on_screen(gui):
	if gui.id == agent.gui_curtain.id:
		gui_curtain_loaded = true
