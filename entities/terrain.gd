class_name Terrain
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
	return info.get("tp","TERRAIN")

func get_name() -> String:
	return info.get("n","")

func get_terrain_type() -> String:
	return info.get("tt","")

func get_image_url() -> String:
	return info.get("iu","")

func get_range() -> int:
	return int(info.get("r", 0))

func get_giants_reach() -> int:
	return int(info.get("gr", 0))

func get_thrown_damage() -> int:
	return int(info.get("td", 0))

func get_added_damage() -> String:
	return str(info.get("ad", ""))

func get_damage_to_destroy() -> int:
	return int(info.get("dd", 0))


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

func can_be_thrown() -> bool:
	return get_thrown_damage() > 0
