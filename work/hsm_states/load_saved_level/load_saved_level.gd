extends LimboState

var scene_loaded: bool = false
var scene: ProxyScene
	

func _enter():
	SceneManager.manager_scene_loaded.connect(agent._on_scene_ready)
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.update_progress.connect(agent.gui_progress._on_progress_changed)

	var save_game_file_name: String = agent.SAVE_GAME_FOLDER.path_join("save.tres")
	var scene_path := GameStateService.load_game_state(save_game_file_name)
	GameStateService.set_global_state_value("trigger_load_actor_global_position_from_game_state", true)
	if scene_path.is_empty():
		printerr("LSLLoadSavedLevel: GameStateService.load_game_state() did not return a scene file path.")
	else:
		SceneManager.change_scene(scene_path, {}, false)
	
func _exit():
	SceneManager.manager_scene_loaded.disconnect(agent._on_scene_ready)
	SceneManager.manager_scene_loaded.disconnect(_on_scene_ready)
	SceneManager.update_progress.disconnect(agent.gui_progress._on_progress_changed)
	
	
func _update(_p_delta):
		if scene_loaded:
			scene_loaded = false
			if agent.gui_hud == null or not is_instance_valid(agent.gui_hud):
				var gui_hud_id = GuiManager.add_gui("hud", 0, null)
				agent.gui_hud = GuiManager.get_gui(gui_hud_id)
				
			agent.gui_hud.ui_inventory.inventory_data = GameStateService.get_global_state_value("inventory_data")
			if scene.has_method("setup_hud"):
				scene.setup_hud(agent.gui_hud)
				
			dispatch("to_progress_disappear")


func _on_scene_ready(p_scene: ProxyScene):
	scene = p_scene
	scene_loaded = true
