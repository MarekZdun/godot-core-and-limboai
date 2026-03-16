class_name GDClassUtils
extends Object


static func custom_class_exist(custom_class_name: String) -> bool:
	var exist := false
	for x in ProjectSettings.get_global_class_list():
		if str(x["class"]) == custom_class_name:
			exist = true
			break
	return exist
	
	
static func get_custom_class_name_from_script(script: Script) -> String:
	var custom_class_name := ""
	if script != null:
		for x in ProjectSettings.get_global_class_list():
			if str(x["path"]) == script.resource_path:
				custom_class_name = str(x["class"])
				break
	return custom_class_name 
	
	
static func get_script_from_custom_class_name(custom_class_name: String) -> Script:
	var script: Script = null
	for x in ProjectSettings.get_global_class_list():
		if str(x["class"]) == custom_class_name:
			script = load(x["path"])
			break
	return script
	
	
static func is_object_custom_class(object: Object, custom_class_name: String) -> bool:
	var correct := false
	if object and not custom_class_name.is_empty():
		var script := object.get_script() as GDScript
		correct = script.get_global_name() == custom_class_name
	return correct
	
	
static func is_object_custom_class_or_subclass(object: Object, custom_class_name: String) -> bool:
	var script = object.get_script() as GDScript
	while script:
		if script.get_global_name() == custom_class_name:
			return true
		script = script.get_base_script()
	return false
