class_name SmartSerializer
extends Object
"""
SmartSerializer - A recursive serializer/deserializer for Godot data types.

(c) Pioneer Games
v 2.2

CHANGES v2.2:
- serialize_array_data: script saved as resource_path string instead of object
- serialize_dictionary_data: key_script and value_script saved as resource_path strings
- deserialize_array_data: script loaded from path string via load()
- deserialize_dictionary_data: key_script and value_script loaded from path strings
- deserialize_object_data: removed .assign() — direct assignment preserves typed array
- deserialize_dictionary_data: removed .assign() — direct assignment preserves typed array
- deserialize_array_data: removed nested .assign() — direct append preserves typed array

DESCRIPTION:
This utility class provides methods to convert Godot data types into plain 
Dictionaries and back. It preserves complete type information, handles complex 
nested structures, and supports Godot's type system including typed arrays 
and dictionaries.

KEY FEATURES:
- Recursive serialization of deeply nested structures
- Full type preservation for accurate deserialization
- Supports typed Arrays and Dictionaries (preserves key/value types)
- Comprehensive built-in type support:
  • Vectors: Vector2, Vector2i, Vector3
  • Colors and Rectangles: Color, Rect2, Rect2i
  • Transforms: Transform2D, Transform3D
  • 3D Math: Plane, Quaternion, AABB
  • Paths: NodePath, StringName
  • Packed Arrays: All 9 Packed*Array types
- Custom object support via script path storage
- Metadata system for tracking type information
- Pure Dictionary output (JSON-compatible)

CHANGES v2.1:
- Removed duplicated if/elif type-dispatch blocks in serialize_object_data,
  serialize_dictionary_data, serialize_array_data — all now delegate to
  serialize_variant_data()
- Same refactor applied to all deserialize_*_data functions — all delegate to
  deserialize_variant_data()
- Fixed missing null-check for obj.get_script() in serialize_object_data
- serialize_object_data now supports all types (previously missed Color,
  Rect2, Transform2D, etc.)

USAGE EXAMPLES:
1. Basic serialization:
   var data = {"name": "Player", "score": 100}
   var serialized = SmartSerializer.serialize_variant_data(data)
   var json_string = JSON.stringify(serialized)

2. Typed dictionary preservation:
   var typed_dict: Dictionary[String, int] = {"health": 100, "level": 5}
   var serialized = SmartSerializer.serialize_variant_data(typed_dict)
   var restored = SmartSerializer.deserialize_variant_data(serialized)
   # restored is Dictionary[String, int] with same typing

3. Nested structures:
   var complex = {
	   "player": player_object,
	   "inventory": ["sword", "potion"],
	   "position": Vector2(100, 200)
   }
   var saved = SmartSerializer.serialize_variant_data(complex)

4. Custom objects:
   var my_obj = MyCustomClass.new()
   var obj_data = SmartSerializer.serialize_variant_data(my_obj)
   # Stores script path in metadata for reconstruction

TYPE SUPPORT REFERENCE:
- Basic types: int, float, String, bool, etc.
- Math types: Vector2, Vector2i, Vector3, Color, Rect2, Rect2i
- Transform types: Transform2D, Transform3D, Plane, Quaternion, AABB
- Container types: Dictionary (typed/untyped), Array (typed/untyped)
- Packed arrays: Byte, Int32, Int64, Float32, Float64, String, Vector2, Vector3, Color
- Path types: NodePath, StringName
- Custom objects: via script path

NOTES:
- RID type is not serialized (internal engine resource)
- Object serialization requires script file to exist at same path
- Typed containers preserve their type constraints when deserialized
- Metadata field stores type information separately from values
"""


static func serialize_variant_data(variant) -> Dictionary:
	var variant_type: int = typeof(variant)
	match variant_type:
		TYPE_OBJECT:
			return serialize_object_data(variant)
		TYPE_DICTIONARY:
			return serialize_dictionary_data(variant)
		TYPE_ARRAY:
			return serialize_array_data(variant)
		TYPE_VECTOR2:
			return serialize_vector2_data(variant)
		TYPE_VECTOR2I:
			return serialize_vector2i_data(variant)
		TYPE_VECTOR3:
			return serialize_vector3_data(variant)
		TYPE_COLOR:
			return serialize_color_data(variant)
		TYPE_RECT2:
			return serialize_rect2_data(variant)
		TYPE_RECT2I:
			return serialize_rect2i_data(variant)
		TYPE_TRANSFORM2D:
			return serialize_transform2d_data(variant)
		TYPE_TRANSFORM3D:
			return serialize_transform3d_data(variant)
		TYPE_PLANE:
			return serialize_plane_data(variant)
		TYPE_QUATERNION:
			return serialize_quaternion_data(variant)
		TYPE_AABB:
			return serialize_aabb_data(variant)
		TYPE_NODE_PATH:
			return serialize_nodepath_data(variant)
		TYPE_STRING_NAME:
			return serialize_stringname_data(variant)
		TYPE_PACKED_BYTE_ARRAY:
			return serialize_packed_byte_array(variant)
		TYPE_PACKED_INT32_ARRAY:
			return serialize_packed_int32_array(variant)
		TYPE_PACKED_INT64_ARRAY:
			return serialize_packed_int64_array(variant)
		TYPE_PACKED_FLOAT32_ARRAY:
			return serialize_packed_float32_array(variant)
		TYPE_PACKED_FLOAT64_ARRAY:
			return serialize_packed_float64_array(variant)
		TYPE_PACKED_STRING_ARRAY:
			return serialize_packed_string_array(variant)
		TYPE_PACKED_VECTOR2_ARRAY:
			return serialize_packed_vector2_array(variant)
		TYPE_PACKED_VECTOR3_ARRAY:
			return serialize_packed_vector3_array(variant)
		TYPE_PACKED_COLOR_ARRAY:
			return serialize_packed_color_array(variant)
		_:
			return serialize_basic_data(variant)


static func serialize_object_data(obj: Object) -> Dictionary:
	var script = obj.get_script()
	if script == null:
		push_error("SmartSerializer: Object has no script, cannot serialize: ", obj)
		return {"type": typeof(obj), "value": {}, "metadata": {"filepath": ""}}

	var output_data: Dictionary = {
		"type": typeof(obj),
		"value": {},
		"metadata": {
			"filepath": script.resource_path
		}
	}

	for prop in obj.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var prop_name: String = prop.name
			var prop_value = obj.get(prop_name)
			output_data.value[prop_name] = serialize_variant_data(prop_value)

	return output_data


static func serialize_dictionary_data(dic: Dictionary) -> Dictionary:
	var output_data: Dictionary = {
		"type": typeof(dic),
		"value": {},
		"metadata": {
			"typed": dic.is_typed(),
			"key_builtin": dic.get_typed_key_builtin(),
			"key_class_name": dic.get_typed_key_class_name(),
			"key_script": dic.get_typed_key_script().resource_path if dic.get_typed_key_script() else "",
			"value_builtin": dic.get_typed_value_builtin(),
			"value_class_name": dic.get_typed_value_class_name(),
			"value_script": dic.get_typed_value_script().resource_path if dic.get_typed_value_script() else ""
		}
	}

	for key in dic:
		output_data.value[key] = serialize_variant_data(dic[key])

	return output_data


static func serialize_array_data(arr: Array) -> Dictionary:
	var output_data: Dictionary = {
		"type": typeof(arr),
		"value": [],
		"metadata": {
			"typed": arr.is_typed(),
			"builtin": arr.get_typed_builtin(),
			"class_name": arr.get_typed_class_name(),
			"script": arr.get_typed_script().resource_path if arr.get_typed_script() else ""
		}
	}

	for value in arr:
		output_data.value.append(serialize_variant_data(value))

	return output_data


static func serialize_vector2_data(vec2: Vector2) -> Dictionary:
	return {
		"type": typeof(vec2),
		"value": {"x": vec2.x, "y": vec2.y}
	}


static func serialize_vector2i_data(vec2i: Vector2i) -> Dictionary:
	return {
		"type": typeof(vec2i),
		"value": {"x": vec2i.x, "y": vec2i.y}
	}


static func serialize_vector3_data(vec3: Vector3) -> Dictionary:
	return {
		"type": typeof(vec3),
		"value": {"x": vec3.x, "y": vec3.y, "z": vec3.z}
	}


static func serialize_basic_data(basic) -> Dictionary:
	return {
		"type": typeof(basic),
		"value": basic
	}


static func serialize_color_data(color: Color) -> Dictionary:
	return {
		"type": typeof(color),
		"value": {"r": color.r, "g": color.g, "b": color.b, "a": color.a}
	}


static func serialize_rect2_data(rect: Rect2) -> Dictionary:
	return {
		"type": typeof(rect),
		"value": {
			"position": {"x": rect.position.x, "y": rect.position.y},
			"size": {"x": rect.size.x, "y": rect.size.y}
		}
	}


static func serialize_rect2i_data(rect: Rect2i) -> Dictionary:
	return {
		"type": typeof(rect),
		"value": {
			"position": {"x": rect.position.x, "y": rect.position.y},
			"size": {"x": rect.size.x, "y": rect.size.y}
		}
	}


static func serialize_transform2d_data(transform: Transform2D) -> Dictionary:
	return {
		"type": typeof(transform),
		"value": {
			"x": {"x": transform.x.x, "y": transform.x.y},
			"y": {"x": transform.y.x, "y": transform.y.y},
			"origin": {"x": transform.origin.x, "y": transform.origin.y}
		}
	}


static func serialize_transform3d_data(transform: Transform3D) -> Dictionary:
	return {
		"type": typeof(transform),
		"value": {
			"basis": {
				"x": {"x": transform.basis.x.x, "y": transform.basis.x.y, "z": transform.basis.x.z},
				"y": {"x": transform.basis.y.x, "y": transform.basis.y.y, "z": transform.basis.y.z},
				"z": {"x": transform.basis.z.x, "y": transform.basis.z.y, "z": transform.basis.z.z}
			},
			"origin": {"x": transform.origin.x, "y": transform.origin.y, "z": transform.origin.z}
		}
	}


static func serialize_plane_data(plane: Plane) -> Dictionary:
	return {
		"type": typeof(plane),
		"value": {
			"normal": {"x": plane.normal.x, "y": plane.normal.y, "z": plane.normal.z},
			"d": plane.d
		}
	}


static func serialize_quaternion_data(quat: Quaternion) -> Dictionary:
	return {
		"type": typeof(quat),
		"value": {"x": quat.x, "y": quat.y, "z": quat.z, "w": quat.w}
	}


static func serialize_aabb_data(aabb: AABB) -> Dictionary:
	return {
		"type": typeof(aabb),
		"value": {
			"position": {"x": aabb.position.x, "y": aabb.position.y, "z": aabb.position.z},
			"size": {"x": aabb.size.x, "y": aabb.size.y, "z": aabb.size.z}
		}
	}


static func serialize_nodepath_data(path: NodePath) -> Dictionary:
	return {
		"type": typeof(path),
		"value": str(path)
	}


static func serialize_stringname_data(name: StringName) -> Dictionary:
	return {
		"type": typeof(name),
		"value": String(name)
	}


static func serialize_packed_byte_array(arr: PackedByteArray) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_int32_array(arr: PackedInt32Array) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_int64_array(arr: PackedInt64Array) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_float32_array(arr: PackedFloat32Array) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_float64_array(arr: PackedFloat64Array) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_string_array(arr: PackedStringArray) -> Dictionary:
	return {"type": typeof(arr), "value": Array(arr)}


static func serialize_packed_vector2_array(arr: PackedVector2Array) -> Dictionary:
	var result = []
	for vec in arr:
		result.append({"x": vec.x, "y": vec.y})
	return {"type": typeof(arr), "value": result}


static func serialize_packed_vector3_array(arr: PackedVector3Array) -> Dictionary:
	var result = []
	for vec in arr:
		result.append({"x": vec.x, "y": vec.y, "z": vec.z})
	return {"type": typeof(arr), "value": result}


static func serialize_packed_color_array(arr: PackedColorArray) -> Dictionary:
	var result = []
	for color in arr:
		result.append({"r": color.r, "g": color.g, "b": color.b, "a": color.a})
	return {"type": typeof(arr), "value": result}


# ---------------------------------------------------------------------------
# DESERIALIZATION
# ---------------------------------------------------------------------------

static func deserialize_variant_data(text_data: Dictionary) -> Variant:
	var type: int = text_data.type
	var metadata = text_data.get("metadata")

	match type:
		TYPE_OBJECT:
			if metadata and metadata.get("filepath", ""):
				return deserialize_object_data(text_data)
			return null
		TYPE_DICTIONARY:
			return deserialize_dictionary_data(text_data)
		TYPE_ARRAY:
			return deserialize_array_data(text_data)
		TYPE_VECTOR2:
			return deserialize_vector2_data(text_data)
		TYPE_VECTOR2I:
			return deserialize_vector2i_data(text_data)
		TYPE_VECTOR3:
			return deserialize_vector3_data(text_data)
		TYPE_COLOR:
			return deserialize_color_data(text_data)
		TYPE_RECT2:
			return deserialize_rect2_data(text_data)
		TYPE_RECT2I:
			return deserialize_rect2i_data(text_data)
		TYPE_TRANSFORM2D:
			return deserialize_transform2d_data(text_data)
		TYPE_TRANSFORM3D:
			return deserialize_transform3d_data(text_data)
		TYPE_PLANE:
			return deserialize_plane_data(text_data)
		TYPE_QUATERNION:
			return deserialize_quaternion_data(text_data)
		TYPE_AABB:
			return deserialize_aabb_data(text_data)
		TYPE_NODE_PATH:
			return deserialize_nodepath_data(text_data)
		TYPE_STRING_NAME:
			return deserialize_stringname_data(text_data)
		TYPE_PACKED_BYTE_ARRAY:
			return deserialize_packed_byte_array(text_data)
		TYPE_PACKED_INT32_ARRAY:
			return deserialize_packed_int32_array(text_data)
		TYPE_PACKED_INT64_ARRAY:
			return deserialize_packed_int64_array(text_data)
		TYPE_PACKED_FLOAT32_ARRAY:
			return deserialize_packed_float32_array(text_data)
		TYPE_PACKED_FLOAT64_ARRAY:
			return deserialize_packed_float64_array(text_data)
		TYPE_PACKED_STRING_ARRAY:
			return deserialize_packed_string_array(text_data)
		TYPE_PACKED_VECTOR2_ARRAY:
			return deserialize_packed_vector2_array(text_data)
		TYPE_PACKED_VECTOR3_ARRAY:
			return deserialize_packed_vector3_array(text_data)
		TYPE_PACKED_COLOR_ARRAY:
			return deserialize_packed_color_array(text_data)
		_:
			return text_data.value


static func deserialize_object_data(text_data: Dictionary) -> Object:
	var value: Dictionary = text_data.value
	if not FileAccess.file_exists(text_data.metadata.filepath):
		push_error("SmartSerializer: Script file not found: ", text_data.metadata.filepath)
		return null

	var obj_res := load(text_data.metadata.filepath)
	var output_data: Object = obj_res.new()

	for prop_name in value:
		var prop_entry: Dictionary = value[prop_name]
		var prop_type: int = prop_entry.type

		if prop_type == TYPE_ARRAY:
			output_data[prop_name] = deserialize_array_data(prop_entry)
		else:
			output_data.set(prop_name, deserialize_variant_data(prop_entry))

	return output_data


static func deserialize_dictionary_data(text_data: Dictionary) -> Dictionary:
	var value: Dictionary = text_data.value
	var metadata: Dictionary = text_data.get("metadata", {})
	var output_data: Dictionary

	if metadata.get("typed", false):
		var key_builtin: int = metadata.get("key_builtin", TYPE_NIL)
		var key_class_name: StringName = metadata.get("key_class_name", "")
		var key_script_path: String = metadata.get("key_script", "")
		var key_script: Variant = load(key_script_path) if not key_script_path.is_empty() else null
		var value_builtin: int = metadata.get("value_builtin", TYPE_NIL)
		var value_class_name: StringName = metadata.get("value_class_name", "")
		var value_script_path: String = metadata.get("value_script", "")
		var value_script: Variant = load(value_script_path) if not value_script_path.is_empty() else null
		output_data = Dictionary({}, key_builtin, key_class_name, key_script, value_builtin, value_class_name, value_script)
	else:
		output_data = {}

	for key in value:
		var prop_entry: Dictionary = value[key]
		var prop_type: int = prop_entry.type

		if prop_type == TYPE_ARRAY:
			output_data[key] = deserialize_array_data(prop_entry)
		else:
			output_data[key] = deserialize_variant_data(prop_entry)

	return output_data


static func deserialize_array_data(text_data: Dictionary) -> Array:
	var value: Array = text_data.value
	var metadata: Dictionary = text_data.get("metadata", {})
	var output_data: Array

	if metadata.get("typed", false):
		var value_builtin: int = metadata.get("builtin", TYPE_NIL)
		var value_class_name: StringName = metadata.get("class_name", "")
		var script_path: String = metadata.get("script", "")
		var value_script: Variant = load(script_path) if not script_path.is_empty() else null
		output_data = Array([], value_builtin, value_class_name, value_script)
	else:
		output_data = []

	for entry in value:
		var prop_entry: Dictionary = entry
		var prop_type: int = prop_entry.type

		if prop_type == TYPE_ARRAY:
			output_data.append(deserialize_array_data(prop_entry))
		else:
			output_data.append(deserialize_variant_data(prop_entry))

	return output_data


static func deserialize_vector2_data(text_data: Dictionary) -> Vector2:
	var value: Dictionary = text_data.value
	return Vector2(value.x, value.y)


static func deserialize_vector2i_data(text_data: Dictionary) -> Vector2i:
	var value: Dictionary = text_data.value
	return Vector2i(value.x, value.y)


static func deserialize_vector3_data(text_data: Dictionary) -> Vector3:
	var value: Dictionary = text_data.value
	return Vector3(value.x, value.y, value.z)


static func deserialize_color_data(text_data: Dictionary) -> Color:
	var value: Dictionary = text_data.value
	return Color(value.r, value.g, value.b, value.a)


static func deserialize_rect2_data(text_data: Dictionary) -> Rect2:
	var value: Dictionary = text_data.value
	return Rect2(Vector2(value.position.x, value.position.y), Vector2(value.size.x, value.size.y))


static func deserialize_rect2i_data(text_data: Dictionary) -> Rect2i:
	var value: Dictionary = text_data.value
	return Rect2i(Vector2i(value.position.x, value.position.y), Vector2i(value.size.x, value.size.y))


static func deserialize_transform2d_data(text_data: Dictionary) -> Transform2D:
	var value: Dictionary = text_data.value
	return Transform2D(
		Vector2(value.x.x, value.x.y),
		Vector2(value.y.x, value.y.y),
		Vector2(value.origin.x, value.origin.y)
	)


static func deserialize_transform3d_data(text_data: Dictionary) -> Transform3D:
	var value: Dictionary = text_data.value
	var b = value.basis
	return Transform3D(
		Basis(
			Vector3(b.x.x, b.x.y, b.x.z),
			Vector3(b.y.x, b.y.y, b.y.z),
			Vector3(b.z.x, b.z.y, b.z.z)
		),
		Vector3(value.origin.x, value.origin.y, value.origin.z)
	)


static func deserialize_plane_data(text_data: Dictionary) -> Plane:
	var value: Dictionary = text_data.value
	return Plane(Vector3(value.normal.x, value.normal.y, value.normal.z), value.d)


static func deserialize_quaternion_data(text_data: Dictionary) -> Quaternion:
	var value: Dictionary = text_data.value
	return Quaternion(value.x, value.y, value.z, value.w)


static func deserialize_aabb_data(text_data: Dictionary) -> AABB:
	var value: Dictionary = text_data.value
	return AABB(
		Vector3(value.position.x, value.position.y, value.position.z),
		Vector3(value.size.x, value.size.y, value.size.z)
	)


static func deserialize_nodepath_data(text_data: Dictionary) -> NodePath:
	return NodePath(text_data.value)


static func deserialize_stringname_data(text_data: Dictionary) -> StringName:
	return StringName(text_data.value)


static func deserialize_packed_byte_array(text_data: Dictionary) -> PackedByteArray:
	return PackedByteArray(text_data.value)


static func deserialize_packed_int32_array(text_data: Dictionary) -> PackedInt32Array:
	return PackedInt32Array(text_data.value)


static func deserialize_packed_int64_array(text_data: Dictionary) -> PackedInt64Array:
	return PackedInt64Array(text_data.value)


static func deserialize_packed_float32_array(text_data: Dictionary) -> PackedFloat32Array:
	return PackedFloat32Array(text_data.value)


static func deserialize_packed_float64_array(text_data: Dictionary) -> PackedFloat64Array:
	return PackedFloat64Array(text_data.value)


static func deserialize_packed_string_array(text_data: Dictionary) -> PackedStringArray:
	return PackedStringArray(text_data.value)


static func deserialize_packed_vector2_array(text_data: Dictionary) -> PackedVector2Array:
	var result = PackedVector2Array()
	for vec_data in text_data.value:
		result.append(Vector2(vec_data.x, vec_data.y))
	return result


static func deserialize_packed_vector3_array(text_data: Dictionary) -> PackedVector3Array:
	var result = PackedVector3Array()
	for vec_data in text_data.value:
		result.append(Vector3(vec_data.x, vec_data.y, vec_data.z))
	return result


static func deserialize_packed_color_array(text_data: Dictionary) -> PackedColorArray:
	var result = PackedColorArray()
	for color_data in text_data.value:
		result.append(Color(color_data.r, color_data.g, color_data.b, color_data.a))
	return result
