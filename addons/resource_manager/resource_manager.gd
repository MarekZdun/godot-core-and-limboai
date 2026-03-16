extends Node

var _providers: Dictionary[String, ResourceProvider] = {}


func provide_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		push_error("provide_resource: file does not exist: %s" % path)
		return null
	
	var dir: String = path.get_base_dir() + "/"
	var name: String = path.get_file().get_basename().to_lower()
	var extension: String = path.get_extension()
	
	if not _providers.has(dir):
		_providers[dir] = ResourceProvider.new(dir, [extension], false, ResourceProvider.CACHE_MODE.KEEP)
	
	return _providers[dir].get_resource(name)


func get_providers() -> Dictionary[String, ResourceProvider]:
	return _providers.duplicate()


func get_provider(dir: String) -> ResourceProvider:
	if not _providers.has(dir):
		push_error("get_provider: provider does not exist for directory: %s" % dir)
		return null
	return _providers[dir]


func has_provider(dir: String) -> bool:
	return _providers.has(dir)


func get_provider_count() -> int:
	return _providers.size()


func release_provider(dir: String) -> void:
	if not _providers.has(dir):
		push_error("release_provider: provider does not exist for directory: %s" % dir)
		return
	_providers.erase(dir)


func release_all_providers() -> void:
	_providers.clear()


func get_cached_resource_count() -> int:
	var count: int = 0
	for provider: ResourceProvider in _providers.values():
		count += provider._resources_instances.size()
	return count


func register_provider(provider: ResourceProvider, dir: String) -> void:
	if _providers.has(dir):
		push_error("register_provider: provider already exists for directory: %s" % dir)
		return
	_providers[dir] = provider
