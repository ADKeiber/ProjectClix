class_name GameObject
extends RefCounted

var objectType: Type
var info: Dictionary = {}
var object_id: int

enum Type {FIGURE, SPECIAL_OBJECT, ONE_SHOT, TERRAIN, TERRAIN_MARKER, BYSTANDER, EQUIPMENT, MAP}

func generated_object_id() -> void:
	object_id = randi_range(1, 9_999_999_999)
