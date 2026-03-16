class_name ArrayUtil
extends Object


static func unique_array(arr: Array) -> Array:
	var dict := {}
	for a in arr:
		dict[a] = null
	return dict.keys()
