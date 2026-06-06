class_name Equipment
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
	return str(info.get("tp", "EQUIPMENT"))

func get_name() -> String:
	return str(info.get("n", ""))

func get_special_power_title() -> String:
	return str(info.get("spt", ""))

func get_description() -> String:
	return str(info.get("d", ""))

func get_image_url() -> String:
	return str(info.get("i", ""))

func get_point_value() -> int:
	return int(info.get("c", 0))

#########################################################
## EQUIPMENT RESTRICTIONS
#########################################################

func get_qualifying_name():
	return info.get("qn", "")

func get_qualifying_keywords():
	return info.get("qk", "")

#########################################################
## EQUIP / UNEQUIP
#########################################################

func get_equip():
	return info.get("eq", "")

func get_unequip():
	return info.get("ue", "")

#########################################################
## HELPERS
#########################################################

func has_qualifying_name() -> bool:
	return get_qualifying_name() != ""

func has_qualifying_keywords() -> bool:
	return get_qualifying_keywords() != ""

func is_free() -> bool:
	return get_point_value() <= 0

func can_equip() -> bool:
	return get_equip() != ""

func can_unequip() -> bool:
	return get_unequip() != ""
