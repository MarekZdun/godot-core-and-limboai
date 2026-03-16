extends LimboState

func _enter():
	if SceneManager.current_scene:
		agent.next_scene_id = SceneManager.current_scene.id
		#dispatch("to_play_level")	#???
	else:
		dispatch("to_main_menu")
	
	
func _exit():
	pass
	
	
func _update(_p_delta):
	pass
