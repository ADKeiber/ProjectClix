class_name TerrainMarker
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
	return info.get("tp", "TERRAIN_MARKER")

func get_name() -> String:
	return info.get("n", "")

func get_terrain_type() -> String:
	return info.get("tt", "")

func get_description() -> String:
	return info.get("d", "")

func get_image_url() -> String:
	return info.get("iu", "")

func get_point_value() -> int:
	return int(info.get("c", 0))

# =========================================================
# HELPERS
# =========================================================

func is_blocking() -> bool:
	return get_terrain_type() == "BLOCKING"

func is_hindering() -> bool:
	return get_terrain_type() == "HINDERING"

func is_water() -> bool:
	return get_terrain_type() == "WATER"

func is_elevated() -> bool:
	return get_terrain_type() == "ELEVATED"

func is_free() -> bool:
	return get_point_value() <= 0
