class_name GameState
extends Node

signal get_figures_data(username: String)
signal refresh_state()
signal session_joined()
signal import_team(peer_id: int, data: Dictionary[String, Variant])

var players: Dictionary[int,Player]  = {} # Data is peer ID, Player information
var units_data: Dictionary

func get_player_by_username(username: String) -> Player :
	for player_id in players:
		if players[player_id].username == username:
			return players[player_id]
	return null

######################################
## Client to host data sync
######################################
#Register new player with HOST
@rpc("any_peer", "reliable")
func register_player(username: String) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	print("Player registered: ", username)
	var player: Player = Player.new()
	player.username = username
	GState.players[sender_id] = player
	print("USER ADDED TO GLOBAL STATE!")
	GState.refresh_state.emit()

	#Will need to update to transfer more potentially
	var player_data := {}
	for peer_id in GState.players:
		player_data[peer_id] = {
			"username": GState.players[peer_id].username
		}
	sync_players.rpc(player_data)

#Adds team information from a player to the HOST
@rpc("any_peer", "reliable")
func import_team_sync(peer_id: int, gameObjectUrls: Array[String], gameObjectTypes: Array[GameObject.Type]) -> void:
	var player: Player = players[peer_id]
	if player == null:
		return
	player.gameObjectUrls = gameObjectUrls
	player.gameObjectTypes = gameObjectTypes
	if units_data == null:
		load_units()
	get_figures(player.username)
	sync_player_team.rpc(peer_id, gameObjectUrls, gameObjectTypes)

######################################
## Host to Clients data sync
######################################
#client player sync
@rpc("authority", "reliable")
func sync_players(player_data: Dictionary) -> void:
	GState.players.clear()
	for peer_id in player_data:
		var player := Player.new()
		player.username = player_data[peer_id]["username"]
		GState.players[peer_id] = player
	GState.refresh_state.emit()

@rpc("authority", "reliable")
func sync_player_team(peer_id: int, gameObjectUrls: Array[String], gameObjectTypes: Array[GameObject.Type]) -> void:
	var player: Player = players[peer_id]
	if player == null:
		return
	player.gameObjectUrls = gameObjectUrls
	player.gameObjectTypes = gameObjectTypes
	if units_data == null:
		load_units()
	get_figures(player.username)
	print("SYNCED FROM HOST")
	print(player)


########################################
## Loading/finding units
########################################
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

func get_figures(username: String) -> void: 
	var player:Player = get_player_by_username(username)
	if player == null:
		print("Unable to find player in game state!!!!!!!!!!")
		return
	var gameObjects: Array[GameObject] = []
	var i: int = 0
	while( i < len(player.gameObjectUrls)):
		gameObjects.append(get_object_from_url(player.gameObjectUrls[i], player.gameObjectTypes[i]))
		#player.gameObjects.append(get_object_from_url(player.gameObjectUrls[i], player.gameObjectTypes[i]))
		i = i + 1
	player.gameObjects = gameObjects
	#TODO - emit signal to send player info to host and from host to ci
	print(player)

func my_peer_id() -> int:
	return multiplayer.get_unique_id()
