class_name OneShot
extends GameObject


# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "ONE_SHOT"

# n
var objectName: String = ""

# d
var description: String = ""

# au
var art_url: String = ""

# p
var points: int = 0


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):

	id = unit_id
	info = data
	generated_object_id()

	type = data.get(
		"tp",
        "ONE_SHOT"
	)

	objectName = data.get(
		"n",
        ""
	)

	description = data.get(
		"d",
        ""
	)

	art_url = data.get(
		"au",
        ""
	)

	points = int(
		data.get("p", 0)
	)


# =========================================================
# HELPERS
# =========================================================

func is_free() -> bool:

	return points <= 0
