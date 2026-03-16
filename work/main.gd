extends Node
"
If you want the information about the removal of the avatar scene (movable) to be saved:
	-set the global property belonging to the GameStateHelper of the avatar scene to false.
	-save the statistics of the avatar scene in the GameStateHelper Main/autoloader, 
		set the global property of this GameStateHelper to true.
	-in the _ready scene of any level scene, after await GameStateService.state_load_completed, 
		get the statistics from Main/autoloader and pass them for the avatar scene.
"

const SAVE_GAME_FOLDER = "user://save_games"

@export var next_scene_id: String
@export_dir var support_dir: String = "res://work/scenes/support/"

var gui_main_menu: ProxyGui
var gui_curtain: ProxyGui
var gui_progress: ProxyGui
var gui_hud: ProxyGui

@onready var main_hsm: LimboHSM = %MainHSM


func _ready():
	randomize()
	SceneManager.scene_transitioning.connect(GameStateService.on_scene_transitioning)

	var support_preloaded := ResourceProvider.new(support_dir, ["tscn"], false, ResourceProvider.CACHE_MODE.PRELOAD)
	ResourceManager.register_provider(support_preloaded, support_dir)
	
	main_hsm.initialize(self)
	main_hsm.set_active(true)
		
		
func save_game():
	DirAccess.make_dir_recursive_absolute(SAVE_GAME_FOLDER)
	var save_game_file_name := SAVE_GAME_FOLDER.path_join("save.tres")
	GameStateService.save_game_state(save_game_file_name)


func _on_scene_ready(scene: Node):
	print("scene " + scene.id + " is ready")


func _on_scene_gone(scene_id: String):
	print("scene " + scene_id + " has gone")
