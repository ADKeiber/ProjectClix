class_name OneShot
extends GameObject

#########################################################
## INIT
#########################################################

func _init(one_shot_id: String, data: Dictionary):
	set_id = one_shot_id
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

func get_type() -> String:
	return str(info.get("tp", "ONE_SHOT"))

func get_name() -> String:
	return str(info.get("n", ""))

func get_description() -> String:
	return str(info.get("d", ""))

func get_art_url() -> String:
	return str(info.get("au", ""))

func get_points() -> int:
	return int(info.get("p", 0))

#########################################################
## HELPERS
#########################################################

func is_free() -> bool:
	return get_points() <= 0
