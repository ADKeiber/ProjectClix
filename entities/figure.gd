class_name Figure
extends GameObject

# =========================================================
# DATA
# =========================================================

var id: String = ""

# fn
var figure_name: String = ""

# ta
var team_abilities: Array[String] = []

# kw
var keywords: Array[String] = []

# spt
var special_power_types: Array[String] = []

# spn
var special_power_names: Array[String] = []

# spd
var special_power_descriptions: Array[String] = []

# pv
var point_values: Array[int] = []

# ia
# [
#   {
#       "name": String,
#       "description": String
#   }
# ]
var improved_abilities: Array[Dictionary] = []

# r
var range: int = 0

# t
var targets: int = 0

# ss
var stat_symbols: Array[String] = []

# movement
# mca / mcv
var movement_clix_abilities: Array[String] = []
var movement_clix_values: Array[int] = []

# attack
# aca / acv
var attack_clix_abilities: Array[String] = []
var attack_clix_values: Array[int] = []

# defense
# dca / dcv
var defense_clix_abilities: Array[String] = []
var defense_clix_values: Array[int] = []

# damage
# gca / gcv
var damage_clix_abilities: Array[String] = []
var damage_clix_values: Array[int] = []

# dim
var dimension: String = "1x1"


# =========================================================
# INIT
# =========================================================

func _init(unit_id: String, data: Dictionary):
	id = unit_id
	figure_name = data.get("fn", "")
	team_abilities = _string_array(
		data.get("ta", [])
	)
	keywords = _string_array(
		data.get("kw", [])
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
	point_values = _int_array(
		data.get("pv", [])
	)
	range = int(data.get("r", 0))
	targets = int(data.get("t", 0))
	stat_symbols = _string_array(
		data.get("ss", [])
	)
	movement_clix_abilities = _string_array(
		data.get("mca", [])
	)
	movement_clix_values = _int_array(
		data.get("mcv", [])
	)
	attack_clix_abilities = _string_array(
		data.get("aca", [])
	)
	attack_clix_values = _int_array(
		data.get("acv", [])
	)
	defense_clix_abilities = _string_array(
		data.get("dca", [])
	)
	defense_clix_values = _int_array(
		data.get("dcv", [])
	)
	damage_clix_abilities = _string_array(
		data.get("gca", [])
	)
	damage_clix_values = _int_array(
		data.get("gcv", [])
	)
	dimension = data.get("dim", "1x1")
	# improved abilities
	improved_abilities = []

	for ability in data.get("ia", []):
		improved_abilities.append({
			"name": ability.get("ian", ""),
			"description": ability.get("iad", "")
		})


# =========================================================
# HELPERS
# =========================================================

func _string_array(value) -> Array[String]:
	var result: Array[String] = []

	if value is Array:

		for item in value:
			result.append(str(item))

	elif value != null:

		result.append(str(value))

	return result


func _int_array(arr: Array) -> Array[int]:
	var result: Array[int] = []
	for value in arr:
		result.append(int(value))
	return result

# =========================================================
# OPTIONAL HELPERS
# =========================================================

func get_click_count() -> int:
	return movement_clix_values.size()

func has_keyword(keyword: String) -> bool:
	return keyword in keywords

func has_team_ability(ability: String) -> bool:
	return ability in team_abilities

func get_starting_points() -> int:
	if point_values.is_empty():
		return 0
	return point_values[0]
