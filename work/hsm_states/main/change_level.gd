extends LimboHSM

var level_changed: bool = false

@onready var idle: LimboState = %CLIdle
@onready var progress_appear: LimboState = %CLProgressAppear
@onready var curtain_appear: LimboState = %CLCurtainAppear
@onready var load_level: LimboState = %CLLoadLevel
@onready var progress_disappear: LimboState = %CLProgressDisappear
@onready var curtain_disappear: LimboState = %CLCurtainDisappear
@onready var finish_level_load: LimboState = %CLFinishLevelLoad


func _setup() -> void:
	initial_state = idle
	add_transition(idle, curtain_appear, "to_curtain_appear")
	add_transition(curtain_appear, progress_appear, "to_progress_appear")
	add_transition(progress_appear, load_level, "to_load_level")
	add_transition(load_level, progress_disappear, "to_progress_disappear")
	add_transition(progress_disappear, curtain_disappear, "to_curtain_disappear")
	add_transition(curtain_disappear, finish_level_load, "to_finish_level_load")


func _enter():
	finish_level_load.level_changed.connect(_on_level_changed)
	
	
func _exit():
	finish_level_load.level_changed.disconnect(_on_level_changed)
	
	
func _update(_p_delta):
	if level_changed:
		level_changed = false
		dispatch("to_play_level")
	
	
func _on_level_changed():
	level_changed = true
