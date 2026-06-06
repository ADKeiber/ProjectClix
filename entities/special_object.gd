class_name SpecialObject
extends GameObject

# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):
	set_id = unit_id
	info = data
	generated_object_id()

# =========================================================
# GETTERS
# =========================================================

func get_type() -> String:
	return info.get("tp", "SPECIAL_OBJECT")

func get_name() -> String:
	return info.get("n", "")

func get_description() -> String:
	return info.get("d", "")

func get_point_value() -> int:
	return int(info.get("c", 0))

func get_image_url() -> String:
	return info.get("iu", "")

# =========================================================
# HELPERS
# =========================================================

func is_free() -> bool:
	return get_point_value() <= 0
