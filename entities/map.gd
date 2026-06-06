class_name Map
extends GameObject

#########################################################
## INIT
#########################################################

func _init(map_id: String, data: Dictionary):
	set_id = map_id
	info = data
	generated_object_id()

#########################################################
## BASIC DATA
#########################################################

func get_type() -> String:
	return str(info.get("tp", "MAP"))

func get_name() -> String:
	return str(info.get("mn", ""))

func get_map_type() -> String:
	return str(info.get("mt", ""))

#########################################################
## HELPERS
#########################################################

func is_indoor() -> bool:
	return get_map_type().contains("INDOOR")

func is_outdoor() -> bool:
	return get_map_type().contains("OUTDOOR")

func is_indoor_outdoor() -> bool:
	return (
		get_map_type().contains("INDOOR")
		and get_map_type().contains("OUTDOOR")
	)
