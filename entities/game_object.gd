class_name GameObject
extends RefCounted

var objectType: Type
var info: Dictionary = {}
var set_id: String
var object_id: int

enum Type {FIGURE, SPECIAL_OBJECT, ONE_SHOT, TERRAIN, TERRAIN_MARKER, BYSTANDER, EQUIPMENT, MAP}

func generated_object_id() -> void:
	object_id = randi_range(1, 9_999_999_999)

func _get_int(key: String, default: int = 0) -> int:
	return int(info.get(key, default))

func _get_string(key: String, default: String = "") -> String:
	return str(info.get(key, default))

func _get_bool(key: String, default: bool = false) -> bool:
	return bool(info.get(key, default))
