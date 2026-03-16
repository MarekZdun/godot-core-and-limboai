extends LimboHSM

var level_loaded: bool = false
	
@onready var idle: LimboState = %LSLIdle
@onready var curtain_appear: LimboState = %LSLCurtainAppear
@onready var progress_appear: LimboState = %LSLProgressAppear
@onready var curtain_disappear: LimboState = %LSLCurtainDisappear
@onready var progress_disappear: LimboState = %LSLProgressDisappear
@onready var load_saved_level: LimboState = %LSLLoadSavedLevel
@onready var finish_level_load: LimboState = %LSLFinishLevelLoad


func _setup() -> void:
	initial_state = idle
	add_transition(idle, curtain_appear, "to_curtain_appear")
	add_transition(curtain_appear, progress_appear, "to_progress_appear")
	add_transition(progress_appear, load_saved_level, "to_load_saved_level")
	add_transition(load_saved_level, progress_disappear, "to_progress_disappear")
	add_transition(progress_disappear, curtain_disappear, "to_curtain_disappear")
	add_transition(curtain_disappear, finish_level_load, "to_finish_level_load")


func _enter():
	finish_level_load.level_loaded.connect(_on_level_loaded)
	
	
func _exit():
	finish_level_load.level_loaded.disconnect(_on_level_loaded)
	
	
func _update(_p_delta):
	if level_loaded:
		level_loaded = false
		dispatch("to_play_level")
	
	
func _on_level_loaded():
	level_loaded = true
