class_name Map
extends GameObject


# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "MAP"

# mn
var map_name: String = ""

# mt
var map_type: String = ""


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):

	id = unit_id
	info = data
	generated_object_id()

	type = data.get(
		"tp",
        "MAP"
	)

	map_name = data.get(
		"mn",
        ""
	)

	map_type = data.get(
		"mt",
        ""
	)


# =========================================================
# HELPERS
# =========================================================

func is_indoor() -> bool:

	return map_type.contains("INDOOR")


func is_outdoor() -> bool:

	return map_type.contains("OUTDOOR")


func is_indoor_outdoor() -> bool:

	return (
		map_type.contains("INDOOR")
		and map_type.contains("OUTDOOR")
	)
