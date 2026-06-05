class_name Player
extends GameObject

var username: String
var ready: bool = false

#these 2 fields are related 
var gameObjectUrls: Array[String]
var gameObjectTypes: Array[GameObject.Type]
#Add other supported game elements 
#Current supports: Figures
var gameObjects: Array[GameObject]


func _to_string() -> String:
	var toString: String = ""
	toString += "Username: " + self.username + "\n"
	toString += "Game Object Urls: " + str(gameObjectUrls) + "\n"
	toString += "Figures: " + str(gameObjects) + "\n"
	toString += "Object Info: " + str(info)
	#Add Team later
	return toString

static func from_dict(data: Dictionary) -> Player:
	var player := Player.new()

	player.username = data.get("username", "")
	player.ready = data.get("ready", false)
	player.gameObjectUrls = data.get("gameObjectUrls", [])
	player.gameObjectTypes = data.get("gameObjectTypes", [])
	var object_ids: Array = data.get("gameObjectsIds", [])
	GState.get_figures(player.username)
	var object_index: int = 0
	for figure in player.gameObjects:
		figure.object_id = object_ids[object_index]
		object_index = object_index + 1
	return player

func to_dict() -> Dictionary:
	var object_ids: Array = []

	for game_object in gameObjects:
		object_ids.append(game_object.get_unique_id())

	return {
		"username": username,
		"ready": ready,
		"gameObjectUrls": gameObjectUrls,
		"gameObjectTypes": gameObjectTypes,
		"gameObjectIds": object_ids
	}
