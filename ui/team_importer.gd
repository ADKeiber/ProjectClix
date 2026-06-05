class_name TeamImporter
extends Control

@onready var add_figure: Button = %AddFigure
@onready var team_import: VBoxContainer = %TeamImport
@onready var GAME_OBJECT_IMPORT_UI = preload("res://ui/game_object_import.tscn")

var num_urls: int = 1

func _on_import_button_pressed() -> void:
	var player: Player = GState.players[GState.my_peer_id()]
	var urls: Array[String] = []
	var gameObjectType: Array[GameObject.Type] = []
	#gets the URL values :)
	for child in team_import.get_children():
		if child.get_url()[len(child.get_url()) - 1] == "/":
			urls.append(child.get_url().substr(0, len(child.get_url()) - 1))
		else:
			urls.append(child.get_url())
		gameObjectType.append(child.get_type())
	player.gameObjectUrls = urls
	player.gameObjectTypes = gameObjectType
	
	GState.players[GState.my_peer_id()] = player
	#GState.get_figures_data.emit(player.username)
	print("MY ID: ", multiplayer.get_unique_id())
	print("IS SERVER: ", multiplayer.is_server())
	if multiplayer.is_server():
		print("Host team sync")
		GState.import_team_sync(1, player.to_dict())
	else:
		GState.import_team_sync.rpc_id(1, GState.my_peer_id(), player.to_dict())
	


func _on_add_figure_pressed() -> void:
	num_urls += 1
	var newObjectImport = GAME_OBJECT_IMPORT_UI.instantiate()
	team_import.add_child(newObjectImport)
	newObjectImport.set_field_name(num_urls)
	print("Added additonal figure field")
