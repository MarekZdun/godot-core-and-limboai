extends LimboHSM

var gui_main_menu: ProxyGui
var gui_curtain: ProxyGui
var gui_progress: ProxyGui
var gui_hud: ProxyGui

@onready var idle: LimboState = %Idle
@onready var main_menu: LimboState = %MainMenu
@onready var change_level: LimboState = %ChangeLevel
@onready var play_level: LimboState = %PlayLevel
@onready var load_saved_level: LimboState = %LoadSavedLevel


func _setup() -> void:
	initial_state = idle
	add_transition(idle, main_menu, "to_main_menu")
	add_transition(idle, play_level, "to_play_level")
	add_transition(main_menu, change_level, "to_change_level")
	add_transition(main_menu, load_saved_level, "to_load_saved_level")
	add_transition(change_level, play_level, "to_play_level")
	add_transition(play_level, main_menu, "to_main_menu")
	add_transition(play_level, change_level, "to_change_level")
	add_transition(play_level, load_saved_level, "to_load_saved_level")
	add_transition(load_saved_level, play_level, "to_play_level")
