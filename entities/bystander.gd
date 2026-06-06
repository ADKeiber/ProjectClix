class_name Bystander
extends GameObject

#########################################################
## INIT
#########################################################

func _init(figure_id: String, data: Dictionary):
	set_id = figure_id
	info = data
	generated_object_id()

#########################################################
## BASIC DATA
#########################################################

func get_type() -> String:
	return str(info.get("tp", "BYSTANDER"))

func get_name() -> String:
	return str(info.get("n", ""))

func get_range() -> int:
	return int(info.get("r", 0))

func get_targets() -> int:
	return int(info.get("t", 0))

func get_image_url() -> String:
	return str(info.get("iu", ""))

func get_team_ability():
	return info.get("ta", "")

#########################################################
## COMBAT TYPES
#########################################################

func get_movement_type() -> String:
	return str(info.get("mt", ""))

func get_attack_type() -> String:
	return str(info.get("at", ""))

func get_defense_type() -> String:
	return str(info.get("dt", ""))

func get_damage_type() -> String:
	return str(info.get("dmt", ""))

#########################################################
## COMBAT VALUES
#########################################################

func get_speed() -> int:
	return int(info.get("mv", 0))

func get_attack() -> int:
	return int(info.get("av", 0))

func get_defense() -> int:
	return int(info.get("dv", 0))

func get_damage() -> int:
	return int(info.get("dmv", 0))

#########################################################
## COMBAT ABILITIES
#########################################################

func get_movement_ability() -> String:
	return str(info.get("ma", "NONE"))

func get_attack_ability() -> String:
	return str(info.get("aa", "NONE"))

func get_defense_ability() -> String:
	return str(info.get("da", "NONE"))

func get_damage_ability() -> String:
	return str(info.get("dma", "NONE"))

#########################################################
## SPECIAL POWERS
#########################################################

func get_special_power_types() -> Array[String]:
	return _string_array(info.get("spt", []))

func get_special_power_names() -> Array[String]:
	return _string_array(info.get("spn", []))

func get_special_power_descriptions() -> Array[String]:
	return _string_array(info.get("spd", []))

#########################################################
## HELPERS
#########################################################

func has_team_ability() -> bool:
	return get_team_ability() != ""

func has_special_powers() -> bool:
	return get_special_power_names().size() > 0

func _string_array(arr: Array) -> Array[String]:
	var result: Array[String] = []
	for value in arr:
		result.append(str(value))
	return result
