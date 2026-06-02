class_name Terrain
extends GameObject


# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "TERRAIN"

# n
var objectName: String = ""

# tt
var terrain_type: String = ""

# iu
var image_url: String = ""

# r
var range: int = 0

# gr
var giants_reach: int = 0

# td
var thrown_damage: int = 0

# ad
var added_damage: String = ""

# dd
var damage_to_destroy: int = 0


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):

	id = unit_id
	info = data
	generated_object_id()

	type = data.get(
		"tp",
        "TERRAIN"
	)

	objectName = data.get(
		"n",
        ""
	)

	terrain_type = data.get(
		"tt",
        ""
	)

	image_url = data.get(
		"iu",
        ""
	)

	range = int(
		data.get("r", 0)
	)

	giants_reach = int(
		data.get("gr", 0)
	)

	thrown_damage = int(
		data.get("td", 0)
	)

	added_damage = str(
		data.get("ad", "")
	)

	damage_to_destroy = int(
		data.get("dd", 0)
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


func can_be_thrown() -> bool:

	return thrown_damage > 0
