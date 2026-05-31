class_name SpecialObject
extends GameObject

# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""
# tp
var type: String = "SPECIAL_OBJECT"
# n
var objectName: String = ""
# d
var description: String = ""
# c
var cost: int = 0
# iu
var image_url: String = ""


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):
	id = unit_id
	type = data.get(
		"tp",
        "SPECIAL_OBJECT"
	)

	objectName = data.get(
		"n",
        ""
	)

	description = data.get(
		"d",
        ""
	)

	cost = int(
		data.get("c", 0)
	)

	image_url = data.get(
		"iu",
        ""
	)


# =========================================================
# HELPERS
# =========================================================

func is_free() -> bool:
	return cost <= 0
