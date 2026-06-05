class_name Figure
extends GameObject

#########################################################
## INIT
#########################################################

func _init(figure_id: String, data: Dictionary):
	set_id = figure_id
	info = data
	generated_object_id()

#########################################################
## IDS
#########################################################

func get_set_id() -> String:
	return set_id

func get_unique_id() -> int:
	return object_id

#########################################################
## BASIC DATA
#########################################################

func get_name() -> String:
	return str(info.get("fn", ""))

func get_range() -> int:
	return int(info.get("r", 0))

func get_targets() -> int:
	return int(info.get("t", 0))

func get_dimension() -> String:
	return str(info.get("dim", "1x1"))

#########################################################
## ARRAYS
#########################################################

func get_team_abilities() -> Array[String]:
	return _string_array(info.get("ta", []))

func get_keywords() -> Array[String]:
	return _string_array(info.get("kw", []))

func get_special_power_types() -> Array[String]:
	return _string_array(info.get("spt", []))

func get_special_power_names() -> Array[String]:
	return _string_array(info.get("spn", []))

func get_special_power_descriptions() -> Array[String]:
	return _string_array(info.get("spd", []))

func get_point_values() -> Array[int]:
	return _int_array(info.get("pv", []))

func get_stat_symbols() -> Array[String]:
	return _string_array(info.get("ss", []))

#########################################################
## DIAL DATA
#########################################################

func get_movement_clix_abilities() -> Array[String]:
	return _string_array(info.get("mca", []))

func get_movement_clix_values() -> Array[int]:
	return _int_array(info.get("mcv", []))

func get_attack_clix_abilities() -> Array[String]:
	return _string_array(info.get("aca", []))

func get_attack_clix_values() -> Array[int]:
	return _int_array(info.get("acv", []))

func get_defense_clix_abilities() -> Array[String]:
	return _string_array(info.get("dca", []))

func get_defense_clix_values() -> Array[int]:
	return _int_array(info.get("dcv", []))

func get_damage_clix_abilities() -> Array[String]:
	return _string_array(info.get("gca", []))

func get_damage_clix_values() -> Array[int]:
	return _int_array(info.get("gcv", []))

#########################################################
## IMPROVED ABILITIES
#########################################################

func get_improved_abilities() -> Array[Dictionary]:
	var abilities: Array[Dictionary] = []
	for ability in info.get("ia", []):
		abilities.append({
			"name": ability.get("ian", ""),
			"description": ability.get("iad", "")
		})
	return abilities

#########################################################
## HELPERS
#########################################################

func get_click_count() -> int:
	return get_movement_clix_values().size()

func has_keyword(keyword: String) -> bool:
	return keyword in get_keywords()

func has_team_ability(ability: String) -> bool:
	return ability in get_team_abilities()

func get_starting_points() -> int:
	var points = get_point_values()
	if points.is_empty():
		return 0
	return points[0]

#########################################################
## ARRAY HELPERS
#########################################################

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
