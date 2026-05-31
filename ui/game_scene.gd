class_name GameScene
extends Node2D

var units_data: Dictionary
@onready var session_creator: SessionCreator = $SessionCreator
@onready var team_importer: TeamImporter = $TeamImporter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GState.get_figures_data.connect(get_figures)
	load_units()
	team_importer.visible = false
	session_creator.visible = true


##########################################
## Team Importer methods
##########################################
func load_units() -> void:
	var file = FileAccess.open("res://python/units.json", FileAccess.READ)
	if file == null:
		print("Failed to open file")
		return
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		print("JSON Parse Error")
		print(json.get_error_message())
		return
	units_data = json.data

#function used to make the request
func get_figures(username: String) -> void:
	#var player:Player = GState.players[username]
	#var gameObjects: Array[GameObject] = []
	#var i: int = 0
	#while( i < len(player.gameObjectUrls)):
		#gameObjects.append(get_object_from_url(player.gameObjectUrls[i], player.gameObjectTypes[i]))
		##player.gameObjects.append(get_object_from_url(player.gameObjectUrls[i], player.gameObjectTypes[i]))
		#i = i + 1
	#player.gameObjects = gameObjects
	#print(player)
	pass

func get_object_from_url(url: String, type: GameObject.Type) -> GameObject:
	var unit_id = url.get_file()
	var data = units_data[unit_id]
	match type:
		GameObject.Type.FIGURE:
			return Figure.new(unit_id, data) as GameObject

		GameObject.Type.SPECIAL_OBJECT:
			return SpecialObject.new(unit_id, data) as GameObject

		GameObject.Type.ONE_SHOT:
			return OneShot.new(unit_id, data) as GameObject

		GameObject.Type.TERRAIN:
			return Terrain.new(unit_id, data) as GameObject

		GameObject.Type.TERRAIN_MARKER:
			return TerrainMarker.new(unit_id, data) as GameObject

		GameObject.Type.BYSTANDER:
			return Bystander.new(unit_id, data) as GameObject

		GameObject.Type.EQUIPMENT:
			return Equipment.new(unit_id, data) as GameObject

		GameObject.Type.MAP:
			return Map.new(unit_id, data)
		_:
			return Figure.new(unit_id, data) as GameObject
	return Figure.new(unit_id, data) as GameObject
