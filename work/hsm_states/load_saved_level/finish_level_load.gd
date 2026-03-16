extends LimboState

signal level_loaded


func _enter():
	level_loaded.emit()
	
	
func _exit():
	pass
	
	
func _update(_p_delta):
	pass
