class_name Player
extends GameObject

@export var username: String


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
