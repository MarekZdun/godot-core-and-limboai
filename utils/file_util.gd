class_name FileUtil
extends Object
"""
FileUtil - Comprehensive file operations utility for Godot.

DESCRIPTION:
FileUtil provides a unified interface for various file operations including
text files, encrypted data, JSON, resources, and object serialization.
It works seamlessly with SmartSerializer for complex data structures.

KEY FEATURES:
- Text file operations (read/write)
- Encrypted file operations (with password protection)
- JSON file handling
- Godot Resource saving/loading (.tres/.res)
- Object serialization via store_var()/get_var()
- Consistent error handling with default values

USAGE EXAMPLES:
1. Basic text file operations:
   # Save text
   var result = FileUtil.save_text("user://save.txt", "Hello World")
   if result == OK:
	   print("File saved successfully")
   
   # Load text (with default value if file doesn't exist)
   var text = FileUtil.load_text("user://save.txt", "default text")
   print(text)

2. Encrypted text files:
# Save with password protection
FileUtil.save_encrypted_text("user://secret.txt", "Top Secret Data", "mypassword")

# Load encrypted file
var secret = FileUtil.load_encrypted_text("user://secret.txt", "mypassword", "")

3. JSON data (perfect for SmartSerializer integration):
# Prepare data (e.g., from SmartSerializer)
var game_state = {
	"level": 5,
	"score": 1000,
	"player": {
		"name": "Marek",
		"position": [10, 20]
    }
}

# Save as JSON (with optional indentation for readability)
FileUtil.save_data_JSON("user://save.json", game_state, "\t")

# Load JSON
var loaded = FileUtil.load_data_JSON("user://save.json", {"default": "value"})

4. Encrypted JSON (secure saves):
# Save encrypted player data
FileUtil.save_encrypted_data_JSON("user://profile.dat", player_data, "password123")

# Load encrypted data
var profile = FileUtil.load_encrypted_data_JSON("user://profile.dat", "password123")

5. Binary data:
# Save dictionary as binary
FileUtil.save_encrypted_data("user://data.bin", {"key": "value"}, "pass")

# Load binary data
var data = FileUtil.load_encrypted_data("user://data.bin", "pass")

6. Godot Objects (any class extending Object):
# Create an object instance
var player = Player.new()  # Player extends Node (which extends Object)
player.health = 100

# Save the object
FileUtil.save_encrypted_object("user://player.obj", player, "savepass")

# Load object back
var loaded_player = FileUtil.load_encrypted_object("user://player.obj", "savepass")
if loaded_player:
    print(loaded_player.health)  # 100

7. Resource files (.tres/.res):
# Save resource
var item = preload("res://items/sword.tres")
FileUtil.save_data_resource("user://custom_sword.tres", item)

# Load resource
var loaded_item = FileUtil.load_data_resource("user://custom_sword.tres")
"""

static func load_text(file_path: String, default_value: String = "") -> String:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return default_value
	var data = file.get_as_text()
	file.close()
	return data
	
	
static func load_encrypted_text(file_path: String, password: String = "pass",  default_value: String = "") -> String:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
	if file == null:
		return default_value
	var data = file.get_as_text()
	file.close()
	return data


static func save_text(file_path: String, data: String) -> int:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(data)
	file.close()
	return OK
	
	
static func save_encrypted_text(file_path: String, data: String, password: String = "pass") -> int:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, password)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(data)
	file.close()
	return OK
		

static func load_encrypted_data(file_path: String, password: String = "pass", default_value = {}) -> Dictionary:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
	if file == null:
		return default_value
	var data = file.get_var(false)
	file.close()
	return data

		
static func save_encrypted_data(file_path: String, data: Dictionary, password: String = "pass") -> int:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, password)
	if file == null:
		return FileAccess.get_open_error()
	file.store_var(data, false)
	file.close()
	return OK
	
	
static func load_encrypted_object(file_path: String, password: String = "pass", default_value = null) -> Object:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
	if file == null:
		return default_value
	var data = file.get_var(true)
	file.close()
	return data

		
static func save_encrypted_object(file_path: String, data: Object, password: String) -> int:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, password)
	if file == null:
		return FileAccess.get_open_error()
	file.store_var(data, true)
	file.close()
	return OK
		
		
static func load_data_resource(file_path: String, default_value = null) -> Resource:
	if not ResourceLoader.exists(file_path):
		return default_value
	return ResourceLoader.load(file_path)
	
	
static func save_data_resource(file_path: String, data: Resource) -> int:
	return ResourceSaver.save(data, file_path)
	
	
static func load_data_JSON(file_path: String, default_value = {}) -> Dictionary:
	var json_text := load_text(file_path)
	if json_text.is_empty():
		return default_value
	var json := JSON.new()
	var err := json.parse(json_text)
	if err != OK:
		print("error parsing data: %s" % json.get_error_message())
		print(json.get_error_message())
		print(json.get_error_line())
		return default_value
	return json.data
	
	
static func load_encrypted_data_JSON(file_path: String, password: String = "pass", default_value = {}) -> Dictionary:
	var json_text := load_encrypted_text(file_path, password, default_value)
	if json_text.is_empty():
		return default_value
	var json := JSON.new()
	var err := json.parse(json_text)
	if err != OK:
		print("error parsing data: %s" % json.get_error_message())
		print(json.get_error_message())
		print(json.get_error_line())
		return default_value
	return json.data
	
	
static func save_data_JSON(file_path: String, data: Dictionary, indent: String = "") -> int:
	if not indent.is_empty():
		return save_text(file_path, JSON.stringify(data, indent))
	return save_text(file_path, JSON.stringify(data))
	
	
static func save_encrypted_data_JSON(file_path: String, data: Dictionary, password: String = "pass", indent: String = "") -> int:
	if not indent.is_empty():
		return save_encrypted_text(file_path, JSON.stringify(data, indent), password)
	return save_encrypted_text(file_path, JSON.stringify(data), password)
