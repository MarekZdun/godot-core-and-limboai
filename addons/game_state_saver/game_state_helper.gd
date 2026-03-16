@tool
@icon("res://addons/game_state_saver/icon_game_state_helper.svg")
class_name GameStateHelper
extends Node
## Use this node to save property values of it's parent node.


## Signal emitted when data is being loaded.  The data dictionary contains
## data that was previously saved for the game object.
## This allows for game objects to have custom loading logic.
## Note: always check if custom data key is in data dictionary before accessing.
signal loading_data(data:Dictionary)
## Signal emitted when data is being saved.  Data added to the data Dictionary will be saved.
## This allows for game objects to have custom saving data.
signal saving_data(data:Dictionary)

# node group for helper nodes
const NODE_GROUP := "GameStateHelper"
# parent node path
const GAME_STATE_KEY_NODE_PATH := "game_state_helper_node_path"
# owner node path
const GAME_STATE_KEY_OWNER_NODE_PATH := "game_state_helper_owner_node_path"
# path to scene file so dynamically instanced nodes can be re-instanced
const GAME_STATE_KEY_INSTANCE_SCENE := "game_state_helper_dynamic_recreate_scene"
# flag indicating that an instanced child scene was freed so that is can be re-freed when scene re-loaded
const GAME_STATE_KEY_PARENT_FREED := "game_state_helper_parent_freed"

"""
This class saves the fact that the instanced child scene was freed.
When the save file is re-loaded, the GameStateHelper node/class will free it again.
"""
class SaveFreedInstancedChildScene:
	var id: String
	var node_path: String
	func _init(save_id: String, save_node_path: String) -> void:
		id = save_id
		node_path = save_node_path
	func save_data(data: Dictionary) -> void:
		var node_data := {}
		# add node data to data dictionary
		data[id] = node_data
		node_data[GAME_STATE_KEY_PARENT_FREED] = true
		node_data[GAME_STATE_KEY_NODE_PATH] = node_path

## Used by GameStateInspector to display a dynamic drop down
@warning_ignore("unused_private_class_variable")
@export var _add_property_editor : String
## A list of parent node property names to save.
@export var save_properties:Array[String] = []
## Check this property (make true) if the parent is dynamically created during your game and
## you want Game State Saver to re-instance it when the scene is reloaded.
@export var dynamic_instance: bool:
	get:
		return _dynamic_instance
	set(value):
		_dynamic_instance = value
		if value:
			_global = false
		notify_property_list_changed()
		
## Flag indicating if the data is to be saved/loaded to the global game state dictionary (true) or
## saved/loaded on a per-scene basis.
@export var global: bool:
	get:
		return _global
	set(value):
		_global = value
		if value:
			_dynamic_instance = false
		notify_property_list_changed()
		
## Causes a breakpoint to be executed in the GameStateService.  Used for debugging the
## save_data() and load_data() functions.
@export var debug := false

var _dynamic_instance: bool = false
var _global: bool = false


func _enter_tree() -> void:
	# must add to group since this is just a GDScript file (no scene file)
	add_to_group(NODE_GROUP)
	if has_user_signal("instanced_child_scene_freed"):
		return
	# signal to let service know that a instanced child scene was freed
	# add this signal this way hides it in the signal panel - it's only meant for the service
	add_user_signal("instanced_child_scene_freed", [
		{
			"save_freeds_instanced_child_scene_object": TYPE_OBJECT
		}
		])


## Saves property values from it's parent to the given data dictionary.  Called from the 
## GameStateService.
func save_data(scene_node_data_or_global_state: Dictionary) -> void:
	var parent := get_parent()
	var id := GameStateHelper.get_id_with_validation(parent, scene_node_data_or_global_state)
	var old_name := get_last_node_name_from_path(str(parent.get_path()))
	var new_name := get_last_node_name_from_path(id)
	if old_name != new_name:
		push_warning("Renaming node: %s → %s" % [old_name, new_name])
		parent.name = new_name

	var node_data := {}
	if _global:
		node_data = scene_node_data_or_global_state
	else:
		# add node data to data dictionary
		scene_node_data_or_global_state[id] = node_data
		
	var active_scene_container := get_node_or_null(GameStateService.ACTIVE_SCENE_CONTAINER_NODE_PATH)
	var active_scene: Node = null
	if active_scene_container.get_child_count() > 0:
		active_scene = active_scene_container.get_child(0)
	
	if _dynamic_instance and !parent.owner and !_global and parent != active_scene:
		# no owner means the parent was instanced - save the scene file path so it can be re-instanced
		node_data[GAME_STATE_KEY_INSTANCE_SCENE] = parent.scene_file_path
		
	#save path - makes data easier to identifier in save file for debugging
	# also used to find parent to instanced scenes
	if !_global:
		node_data[GAME_STATE_KEY_NODE_PATH] = parent.get_path()
		if parent.owner:
			node_data[GAME_STATE_KEY_OWNER_NODE_PATH] = str(parent.owner.get_path())
	
	# add property values to node data
	for prop_name in save_properties:
		node_data[prop_name] = parent.get_indexed(prop_name)
	
	# emit signal - allows parent to have it's own save code/logic
	saving_data.emit(node_data)


## Loads property values from data dictionary and sets them on parent.  Called
## from the GameStateService.
func load_data(scene_node_data_or_global_state: Dictionary) -> void:
	var parent := get_parent()
	var id := str(parent.get_path())
	
	var node_data: Dictionary
	
	if _global:
		node_data = scene_node_data_or_global_state
	elif scene_node_data_or_global_state.has(id):
		node_data = scene_node_data_or_global_state[id]
	else:
		# emit signal - allows parent o have it's own load code/logic
		loading_data.emit(node_data)
		return
	
	# if parent was noted as being freed in the save file - free it again
	if node_data.has(GAME_STATE_KEY_PARENT_FREED):
		if node_data[GAME_STATE_KEY_PARENT_FREED]:
			parent.queue_free()
			return
	
	# set parent property values
	for prop_name in save_properties:
		if node_data.has(prop_name):
			parent.set_indexed(prop_name, node_data[prop_name])
	
	# emit signal - allows parent o have it's own load code/logic
	loading_data.emit(node_data)


## creates an ID for saving/loading game object data.
static func get_id(node:Node) -> String:
	return str(node.get_path()).replace("@", "_")
	
	
static func get_id_with_validation(node: Node, node_path_database: Dictionary) -> String:
	var node_path : = str(node.get_path())
	var base_path := node_path.replace("@", "_")
	if not node_path_database.has(base_path):
		return base_path
		
	var last_underscore := base_path.rfind("_")
	if last_underscore == -1:
		return base_path + "_1"
		
	var path_without_number := base_path.substr(0, last_underscore)
	var current_number_str := base_path.substr(last_underscore + 1)
	var current_number := current_number_str.to_int()
	
	if current_number == 0 and current_number_str != "0":
		current_number = 1
		path_without_number = base_path
		
	var counter = max(1, current_number)
	var new_path = path_without_number + "_" + str(counter)
	
	while node_path_database.has(new_path):
		counter += 1
		new_path = path_without_number + "_" + str(counter)
	
	return new_path
	
	
func get_last_node_name_from_path(node_path_str: String) -> String:
	var node_path := NodePath(node_path_str)
	return node_path.get_name(node_path.get_name_count() - 1)


"""
If parent exits the tree, let manager know so we save this fact in the save file.
"""
func _exit_tree() -> void:
	if _dynamic_instance:
		return
	var parent := get_parent()
	var id := GameStateHelper.get_id(parent)
	var save_freed_object := SaveFreedInstancedChildScene.new(id, id)
	
	emit_signal("instanced_child_scene_freed", save_freed_object)
