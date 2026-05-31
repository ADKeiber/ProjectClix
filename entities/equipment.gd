class_name Equipment
extends GameObject

# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "EQUIPMENT"

# n
var object_name: String = ""

# spt
var special_power_title: String = ""

# qn
var qualifying_name: Variant = null

# qk
var qualifying_keywords: Variant = null

# eq
var equip: Variant = null

# ue
var unequip: Variant = null

# d
var description: String = ""

# i
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
        "EQUIPMENT"
	)

	object_name = data.get(
		"n",
        ""
	)

	special_power_title = data.get(
		"spt",
        ""
	)

	qualifying_name = data.get(
		"qn",
        ""
	)

	qualifying_keywords = data.get(
		"qk",
        ""
	)

	equip = data.get(
		"eq",
        ""
	)

	unequip = data.get(
		"ue",
        ""
	)

	description = data.get(
		"d",
        ""
	)

	image_url = data.get(
		"i",
        ""
	)

	cost = int(
		data.get("c", 0)
	)


# =========================================================
# HELPERS
# =========================================================

func has_qualifying_name() -> bool:

	return qualifying_name != ""


func has_qualifying_keywords() -> bool:

	return qualifying_keywords != ""


func is_free() -> bool:

	return cost <= 0


func can_equip() -> bool:

	return equip != ""


func can_unequip() -> bool:

	return unequip != ""
