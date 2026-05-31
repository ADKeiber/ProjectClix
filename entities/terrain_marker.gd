class_name TerrainMarker
extends GameObject

# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "TERRAIN_MARKER"

# n
var objectName: String = ""

# tt
var terrain_type: String = ""

# d
var description: String = ""

# iu
var image_url: String = ""

# c
var cost: int = 0


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):

	id = unit_id

	type = data.get(
		"tp",
        "TERRAIN_MARKER"
	)

	objectName = data.get(
		"n",
        ""
	)

	terrain_type = data.get(
		"tt",
        ""
	)

	description = data.get(
		"d",
        ""
	)

	image_url = data.get(
		"iu",
        ""
	)

	cost = int(
		data.get("c", 0)
	)


# =========================================================
# HELPERS
# =========================================================

func is_blocking() -> bool:

	return terrain_type == "BLOCKING"


func is_hindering() -> bool:

	return terrain_type == "HINDERING"


func is_water() -> bool:

	return terrain_type == "WATER"


func is_elevated() -> bool:

	return terrain_type == "ELEVATED"


func is_free() -> bool:

	return cost <= 0
