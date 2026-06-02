class_name Bystander
extends GameObject


# =========================================================
# DATA
# =========================================================

# unit id from json key
var id: String = ""

# tp
var type: String = "BYSTANDER"

# n
var objectName: String = ""

# r
var range: int = 0

# t
var targets: int = 0

# iu
var image_url: String = ""

# combat types
# mt / at / dt / dmt
var movement_type: String = ""
var attack_type: String = ""
var defense_type: String = ""
var damage_type: String = ""

# ta
var team_ability: Variant = null

# movement
# mv / ma
var movement_value: int = 0
var movement_ability: String = "NONE"

# attack
# av / aa
var attack_value: int = 0
var attack_ability: String = "NONE"

# defense
# dv / da
var defense_value: int = 0
var defense_ability: String = "NONE"

# damage
# dmv / dma
var damage_value: int = 0
var damage_ability: String = "NONE"

# special powers
# spt / spn / spd
var special_power_types: Array[String] = []
var special_power_names: Array[String] = []
var special_power_descriptions: Array[String] = []


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):

	id = unit_id
	info = data
	generated_object_id()

	type = data.get(
		"tp",
        "BYSTANDER"
	)

	objectName = data.get(
		"n",
        ""
	)

	range = int(
		data.get("r", 0)
	)

	targets = int(
		data.get("t", 0)
	)

	image_url = data.get(
		"iu",
        ""
	)

	movement_type = data.get(
		"mt",
        ""
	)

	attack_type = data.get(
		"at",
        ""
	)

	defense_type = data.get(
		"dt",
        ""
	)

	damage_type = data.get(
		"dmt",
        ""
	)

	team_ability = data.get(
		"ta",
        ""
	)

	movement_value = int(
		data.get("mv", 0)
	)

	movement_ability = data.get(
		"ma",
        "NONE"
	)

	attack_value = int(
		data.get("av", 0)
	)

	attack_ability = data.get(
		"aa",
        "NONE"
	)

	defense_value = int(
		data.get("dv", 0)
	)

	defense_ability = data.get(
		"da",
        "NONE"
	)

	damage_value = int(
		data.get("dmv", 0)
	)

	damage_ability = data.get(
		"dma",
        "NONE"
	)

	special_power_types = _string_array(
		data.get("spt", [])
	)

	special_power_names = _string_array(
		data.get("spn", [])
	)

	special_power_descriptions = _string_array(
		data.get("spd", [])
	)


# =========================================================
# HELPERS
# =========================================================

func _string_array(arr: Array) -> Array[String]:

	var result: Array[String] = []

	for value in arr:
		result.append(str(value))

	return result


func has_team_ability() -> bool:

	return team_ability != ""


func has_special_powers() -> bool:

	return special_power_names.size() > 0


func get_speed() -> int:

	return movement_value


func get_attack() -> int:

	return attack_value


func get_defense() -> int:

	return defense_value


func get_damage() -> int:

	return damage_value
