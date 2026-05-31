class_name Player
extends GameObject

@export var username: String


#these 2 fields are related 
@export var gameObjectUrls: Array[String]
@export var gameObjectTypes: Array[GameObject.Type]
#Add other supported game elements 
#Current supports: Figures
@export var gameObjects: Array[GameObject]


func _to_string() -> String:
	var toString: String = ""
	toString += "Username: " + self.username + "\n"
	toString += "Game Object Urls: " + str(gameObjectUrls) + "\n"
	toString += "Figures: " + str(gameObjects)
	toString += ""
	#Add Team later
	return toString
