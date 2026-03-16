class_name CommonScene extends ProxyScene

signal exit_level()
signal change_level(next_level_filepath)

enum LevelKeys{LEVEL_KEY_NONE = 0, LEVEL_KEY_1 = KEY_1, LEVEL_KEY_2 = KEY_2}

@export_file_path("*.tscn") var next_level_filepath: String
@export_file_path("*.tscn") var runtime_collectable_filepath: String
@export_file_path("*.tscn") var runtime_collectable_trap_filepath: String
@export_file_path("*.tscn") var runtime_trap_filepath: String
@export var actor_start_pos: Vector2
@export var next_level_key: LevelKeys

var runtimes: Array 

@onready var actor = $Movable


func _ready():
	var runtime_collectable: PackedScene = ResourceManager.provide_resource(runtime_collectable_filepath)
	if runtime_collectable:
		runtimes.append(runtime_collectable)
		
	var runtime_collectable_trap: PackedScene = ResourceManager.provide_resource(runtime_collectable_trap_filepath)
	if runtime_collectable_trap:
		runtimes.append(runtime_collectable_trap)
		
	var runtime_trap: PackedScene = ResourceManager.provide_resource(runtime_trap_filepath)
	if runtime_trap:
		runtimes.append(runtime_trap)
	
	actor.global_position = actor_start_pos


func _unhandled_input(event):	
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ENTER:
#			actor.queue_free()
			pass
		
		elif event.keycode == next_level_key:
			change_level.emit(next_level_filepath)
		
		elif event.keycode == KEY_ESCAPE:
			exit_level.emit()
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var collider = detect_collider(event.position)
			
			if collider:
				collider.queue_free()
			else:
				var runtime_res: PackedScene = runtimes[randi() % runtimes.size()] if runtimes.size() > 0 else null
				if runtime_res:
					var runtime: Node = runtime_res.instantiate()
					runtime.setup(event.global_position)
					add_child(runtime)
					
					
func _start(_params: Dictionary) -> void:
	pass
	
	
func _end() -> void:
	pass


func detect_collider(pos) -> Object:
	var collider = null
	for child in get_children():
		if child is Sprite2D:
			if child.get_rect().has_point(child.to_local(pos)):
				collider = child
				break
		
	return collider
