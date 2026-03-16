@tool
extends EditorPlugin

const RESOURCE_MANAGER_FILEPATH = "res://addons/resource_manager/resource_manager.gd"
const RESOURCE_MANAGER_AUTLOAD_NAME = "ResourceManager"


func _enable_plugin() -> void:
	add_autoload_singleton(RESOURCE_MANAGER_AUTLOAD_NAME, RESOURCE_MANAGER_FILEPATH)


func _disable_plugin() -> void:
	remove_autoload_singleton(RESOURCE_MANAGER_AUTLOAD_NAME)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
