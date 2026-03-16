extends LimboState

signal level_changed


func _enter():
	level_changed.emit()
	
	
func _exit():
	pass
	
	
func _update(_p_delta):
	pass
